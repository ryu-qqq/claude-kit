# Java 영속성 계층 컨벤션

헥사고날 아키텍처에서의 JPA, QueryDSL, 캐싱 전략에 대한 컨벤션입니다.

## 핵심 원칙

### 기본 철학
- **연관관계 매핑 지양**: N+1 문제 방지를 위해 외래키 ID만 사용
- **QueryDSL 우선**: 타입 세이프하고 유지보수가 용이한 쿼리 작성
- **계층별 기술 분리**: 조회는 QueryDSL, 단순 CRUD는 JPA, 대량 처리는 JdbcTemplate
- **애그리게이트 경계 준수**: 도메인 모델의 경계를 명확히 유지

## 패키지 구조

```
adapter/out/persistence/
├── entity/                    # JPA 엔티티
│   ├── [Domain]JpaEntity.java
│   └── common/
│       └── Audit.java        # 공통 감사 필드
├── repository/               # Spring Data JPA Repository
│   └── [Domain]JpaRepository.java
├── query/                    # QueryDSL 전용
│   └── [Domain]QueryRepository.java
├── batch/                    # 배치/벌크 처리
│   └── [Domain]BatchRepository.java
├── mapper/                   # 엔티티 ↔ 도메인 변환
│   └── [Domain]Mapper.java
└── adapter/                  # Port 구현체
    └── [Domain]PersistenceAdapter.java
```

## JPA 엔티티 규칙

### 기본 엔티티 구조
```java
@Entity
@Table(name = "orders")  // 테이블명: snake_case 복수형
@EntityListeners(AuditingEntityListener.class)
public class OrderJpaEntity {  // 엔티티명: [Domain]JpaEntity

    @Id
    @Column(name = "order_id", length = 36)
    private String id;

    // ❌ 연관관계 매핑 지양
    // @ManyToOne
    // private UserJpaEntity user;

    // ✅ 외래키 ID만 저장
    @Column(name = "user_id", nullable = false)
    private String userId;

    @Column(name = "total_amount", nullable = false)
    private BigDecimal totalAmount;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private OrderStatus status;

    @Embedded
    private Audit audit;  // 공통 감사 필드

    @Version
    private Long version;  // 낙관적 락

    // JPA 기본 생성자 (protected 필수)
    protected OrderJpaEntity() {}

    // 도메인 → JPA 변환 (static factory)
    public static OrderJpaEntity from(Order order) {
        OrderJpaEntity entity = new OrderJpaEntity();
        entity.id = order.getId().value();
        entity.userId = order.getUserId().value();
        entity.totalAmount = order.getTotalAmount().amount();
        entity.status = order.getStatus();
        return entity;
    }

    // JPA → 도메인 변환
    public Order toDomain() {
        return Order.reconstitute(
            new OrderId(this.id),
            new UserId(this.userId),
            new Money(this.totalAmount),
            this.status
        );
    }

    // 더티체킹용 업데이트 메서드
    public void updateFrom(Order order) {
        this.totalAmount = order.getTotalAmount().amount();
        this.status = order.getStatus();
    }
}
```

### 공통 감사 필드
```java
@Embeddable
public class Audit {

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @CreatedBy
    @Column(name = "created_by", length = 100, updatable = false)
    private String createdBy;

    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @LastModifiedBy
    @Column(name = "updated_by", length = 100)
    private String updatedBy;

    @Column(name = "deleted_at")
    private LocalDateTime deletedAt;  // Soft delete

    // Soft delete 메서드
    public void delete() {
        this.deletedAt = LocalDateTime.now();
    }

    public boolean isDeleted() {
        return this.deletedAt != null;
    }
}
```

## QueryDSL 사용 전략

### QueryDSL 설정
```java
@Configuration
public class QueryDslConfig {

    @PersistenceContext
    private EntityManager entityManager;

    @Bean
    public JPAQueryFactory jpaQueryFactory() {
        return new JPAQueryFactory(entityManager);
    }
}
```

### QueryRepository 패턴
```java
@Repository
@RequiredArgsConstructor
public class OrderQueryRepository {

    private final JPAQueryFactory queryFactory;

    // 복잡한 조회 - QueryDSL 사용
    public List<Order> findByCondition(OrderSearchCondition condition) {
        return queryFactory
            .selectFrom(order)
            .where(
                userIdEq(condition.getUserId()),
                statusIn(condition.getStatuses()),
                totalAmountBetween(condition.getMinAmount(), condition.getMaxAmount()),
                createdDateBetween(condition.getStartDate(), condition.getEndDate())
            )
            .orderBy(order.createdAt.desc())
            .fetch()
            .stream()
            .map(OrderJpaEntity::toDomain)
            .toList();
    }

    // 페이징 조회
    public Page<OrderSummaryDto> searchPage(OrderSearchCondition condition, Pageable pageable) {
        List<OrderSummaryDto> content = queryFactory
            .select(Projections.constructor(OrderSummaryDto.class,
                order.id,
                order.userId,
                order.totalAmount,
                order.status,
                order.audit.createdAt
            ))
            .from(order)
            .where(
                searchCondition(condition),
                order.audit.deletedAt.isNull()  // Soft delete 체크
            )
            .offset(pageable.getOffset())
            .limit(pageable.getPageSize())
            .orderBy(getOrderSpecifier(pageable.getSort()))
            .fetch();

        // Count 쿼리 최적화
        JPAQuery<Long> countQuery = queryFactory
            .select(order.count())
            .from(order)
            .where(
                searchCondition(condition),
                order.audit.deletedAt.isNull()
            );

        return PageableExecutionUtils.getPage(content, pageable, countQuery::fetchOne);
    }

    // 벌크 업데이트 - QueryDSL 사용
    @Transactional
    @Modifying
    public long bulkUpdateStatus(List<String> orderIds, OrderStatus newStatus) {
        return queryFactory
            .update(order)
            .set(order.status, newStatus)
            .set(order.audit.updatedAt, LocalDateTime.now())
            .where(order.id.in(orderIds))
            .execute();
    }

    // 통계 조회
    public List<OrderStatisticsDto> getStatistics(String userId, YearMonth yearMonth) {
        return queryFactory
            .select(Projections.constructor(OrderStatisticsDto.class,
                order.audit.createdAt.dayOfMonth(),
                order.count(),
                order.totalAmount.sum()
            ))
            .from(order)
            .where(
                order.userId.eq(userId),
                order.audit.createdAt.year().eq(yearMonth.getYear()),
                order.audit.createdAt.month().eq(yearMonth.getMonthValue()),
                order.audit.deletedAt.isNull()
            )
            .groupBy(order.audit.createdAt.dayOfMonth())
            .fetch();
    }

    // 동적 쿼리 조건 메서드
    private BooleanExpression userIdEq(String userId) {
        return StringUtils.hasText(userId) ? order.userId.eq(userId) : null;
    }

    private BooleanExpression statusIn(List<OrderStatus> statuses) {
        return CollectionUtils.isEmpty(statuses) ? null : order.status.in(statuses);
    }

    private BooleanExpression totalAmountBetween(BigDecimal min, BigDecimal max) {
        if (min == null && max == null) return null;
        if (min != null && max != null) return order.totalAmount.between(min, max);
        if (min != null) return order.totalAmount.goe(min);
        return order.totalAmount.loe(max);
    }

    private BooleanExpression createdDateBetween(LocalDateTime start, LocalDateTime end) {
        if (start == null && end == null) return null;
        if (start != null && end != null) return order.audit.createdAt.between(start, end);
        if (start != null) return order.audit.createdAt.goe(start);
        return order.audit.createdAt.loe(end);
    }
}
```

## 기술 선택 가이드

### 언제 무엇을 사용할 것인가

| 작업 유형 | 권장 기술 | 이유 |
|---------|----------|------|
| 단순 CRUD | Spring Data JPA | 구현 간단, 기본 기능 충분 |
| 복잡한 조회 | QueryDSL | 타입 세이프, 동적 쿼리 |
| 단건 업데이트 | JPA 더티체킹 | 트랜잭션 관리 용이 |
| 벌크 업데이트 | QueryDSL | 성능 우수, 명확한 쿼리 |
| 통계/집계 | QueryDSL | 복잡한 집계 쿼리 지원 |
| 극한 성능 필요 | JdbcTemplate | 최적화된 네이티브 쿼리 |
| 배치 작업 | JPA + flush/clear | 메모리 관리, 트랜잭션 |

### PersistenceAdapter 구현 예시
```java
@PersistenceAdapter
@RequiredArgsConstructor
public class OrderPersistenceAdapter implements OrderRepositoryPort {

    private final OrderJpaRepository jpaRepository;        // 기본 CRUD
    private final OrderQueryRepository queryRepository;    // QueryDSL 조회
    private final OrderBatchRepository batchRepository;    // 배치 처리

    @Override
    @Transactional
    public Order save(Order order) {
        // 단순 저장 - JPA
        OrderJpaEntity entity = OrderJpaEntity.from(order);
        OrderJpaEntity saved = jpaRepository.save(entity);
        return saved.toDomain();
    }

    @Override
    @Transactional
    public Order update(Order order) {
        // 단건 업데이트 - 더티체킹
        OrderJpaEntity entity = jpaRepository.findById(order.getId().value())
            .orElseThrow(() -> new OrderNotFoundException(order.getId()));

        entity.updateFrom(order);  // 더티체킹 활용
        // save() 호출 불필요

        return entity.toDomain();
    }

    @Override
    public Optional<Order> findById(OrderId orderId) {
        // 단순 조회 - JPA
        return jpaRepository.findById(orderId.value())
            .filter(entity -> !entity.getAudit().isDeleted())
            .map(OrderJpaEntity::toDomain);
    }

    @Override
    public List<Order> findByCondition(OrderSearchCondition condition) {
        // 복잡한 조회 - QueryDSL
        return queryRepository.findByCondition(condition);
    }

    @Override
    @Transactional
    public void updateStatusBulk(List<OrderId> orderIds, OrderStatus status) {
        // 벌크 업데이트 - QueryDSL
        List<String> ids = orderIds.stream()
            .map(OrderId::value)
            .toList();

        queryRepository.bulkUpdateStatus(ids, status);
    }

    @Override
    @Transactional
    public void saveAll(List<Order> orders) {
        // 배치 저장 - JPA 배치
        batchRepository.saveAllInBatch(orders);
    }
}
```

## 배치 처리 전략

### JPA 배치 설정
```yaml
spring:
  jpa:
    properties:
      hibernate:
        jdbc:
          batch_size: 25           # 배치 크기
          batch_versioned_data: true
        order_inserts: true        # INSERT 순서 보장
        order_updates: true        # UPDATE 순서 보장
```

### 배치 Repository 구현
```java
@Repository
@RequiredArgsConstructor
public class OrderBatchRepository {

    @PersistenceContext
    private EntityManager entityManager;

    @Transactional
    public void saveAllInBatch(List<Order> orders) {
        for (int i = 0; i < orders.size(); i++) {
            OrderJpaEntity entity = OrderJpaEntity.from(orders.get(i));
            entityManager.persist(entity);

            // batch_size(25)마다 flush & clear
            if ((i + 1) % 25 == 0) {
                entityManager.flush();  // DB로 전송
                entityManager.clear();  // 1차 캐시 정리
            }
        }

        // 남은 엔티티 처리
        entityManager.flush();
        entityManager.clear();
    }

    @Transactional
    public void updateAllInBatch(List<Order> orders) {
        for (int i = 0; i < orders.size(); i++) {
            OrderJpaEntity entity = entityManager.find(
                OrderJpaEntity.class,
                orders.get(i).getId().value()
            );

            entity.updateFrom(orders.get(i));

            if ((i + 1) % 25 == 0) {
                entityManager.flush();
                entityManager.clear();
            }
        }

        entityManager.flush();
        entityManager.clear();
    }
}
```

## 캐싱 전략

### Redis 캐시 설정
```java
@Configuration
@EnableCaching
public class CacheConfig {

    @Bean
    public CacheManager cacheManager(RedisConnectionFactory connectionFactory) {
        RedisCacheConfiguration defaultConfig = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(60))
            .disableCachingNullValues()
            .serializeKeysWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair
                .fromSerializer(new GenericJackson2JsonRedisSerializer()));

        Map<String, RedisCacheConfiguration> cacheConfigurations = new HashMap<>();

        // 도메인별 캐시 설정
        cacheConfigurations.put("orders", defaultConfig.entryTtl(Duration.ofMinutes(30)));
        cacheConfigurations.put("users", defaultConfig.entryTtl(Duration.ofHours(1)));
        cacheConfigurations.put("products", defaultConfig.entryTtl(Duration.ofHours(6)));

        return RedisCacheManager.builder(connectionFactory)
            .cacheDefaults(defaultConfig)
            .withInitialCacheConfigurations(cacheConfigurations)
            .build();
    }
}
```

### 캐시 적용 예시
```java
@PersistenceAdapter
public class OrderCacheAdapter implements OrderRepositoryPort {

    private final OrderPersistenceAdapter delegate;

    @Override
    @Cacheable(
        value = "orders",
        key = "#orderId.value()",
        condition = "#orderId != null",
        unless = "#result == null"
    )
    public Optional<Order> findById(OrderId orderId) {
        return delegate.findById(orderId);
    }

    @Override
    @CacheEvict(
        value = "orders",
        key = "#order.id.value()"
    )
    public Order save(Order order) {
        return delegate.save(order);
    }

    @Override
    @CacheEvict(
        value = "orders",
        allEntries = true
    )
    public void clearCache() {
        // 캐시 전체 삭제
    }
}
```

## 성능 최적화 체크리스트

### 쿼리 최적화
- [ ] N+1 문제 방지 (연관관계 매핑 지양)
- [ ] 적절한 인덱스 설정
- [ ] 페이징 시 count 쿼리 최적화
- [ ] 불필요한 컬럼 조회 방지 (Projection 활용)

### 배치 처리
- [ ] hibernate.jdbc.batch_size 설정 (권장: 25)
- [ ] flush/clear 패턴 적용
- [ ] 트랜잭션 범위 최적화

### 캐싱
- [ ] 읽기 빈도가 높은 데이터 캐싱
- [ ] 적절한 TTL 설정
- [ ] 캐시 무효화 전략 수립

### 모니터링
- [ ] 슬로우 쿼리 모니터링
- [ ] 캐시 히트율 측정
- [ ] 배치 처리 성능 측정

## 안티패턴

### 피해야 할 패턴
```java
// ❌ N+1 문제 발생
@Entity
public class OrderJpaEntity {
    @OneToMany(fetch = FetchType.EAGER)  // 즉시 로딩
    private List<OrderItemJpaEntity> items;
}

// ❌ 전체 엔티티 조회 후 애플리케이션에서 필터링
List<Order> allOrders = orderRepository.findAll();
List<Order> filtered = allOrders.stream()
    .filter(order -> order.getStatus() == OrderStatus.COMPLETED)
    .toList();

// ❌ 더티체킹 무시하고 save 호출
@Transactional
public void updateOrder(Order order) {
    OrderJpaEntity entity = repository.findById(order.getId()).orElseThrow();
    entity.updateFrom(order);
    repository.save(entity);  // 불필요한 save
}

// ❌ 대량 데이터를 한번에 메모리로 로드
List<Order> allOrders = queryFactory
    .selectFrom(order)
    .fetch();  // OutOfMemoryError 위험
```

## 검증 체크리스트

### 설계 원칙
- [ ] 연관관계 매핑 대신 외래키 ID 사용
- [ ] 애그리게이트 경계 준수
- [ ] 도메인 모델과 JPA 엔티티 분리

### 기술 선택
- [ ] 조회는 QueryDSL 우선 사용
- [ ] 단건 업데이트는 더티체킹 활용
- [ ] 벌크 작업은 QueryDSL 또는 JdbcTemplate
- [ ] 극한 성능이 필요한 경우만 네이티브 쿼리

### 성능
- [ ] N+1 문제 방지
- [ ] 배치 처리 최적화
- [ ] 적절한 캐싱 전략
- [ ] 쿼리 성능 모니터링
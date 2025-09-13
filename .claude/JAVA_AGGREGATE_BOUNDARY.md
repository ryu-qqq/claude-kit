# 애그리게이트 경계 및 의존성 처리 컨벤션

헥사고날 아키텍처에서 애그리게이트 간 의존성 처리와 계층 간 호출 규칙에 대한 컨벤션입니다.

## 핵심 원칙

1. **애그리게이트는 독립적이어야 한다**: 다른 애그리게이트를 직접 참조하지 않음
2. **ID를 통한 느슨한 결합**: 객체 참조 대신 ID 참조
3. **트랜잭션 경계 준수**: 하나의 트랜잭션에서 하나의 애그리게이트만 수정
4. **최종 일관성 허용**: 애그리게이트 간 즉시 일관성 대신 최종 일관성

## 실무에서 사용되는 주요 패턴

### 패턴 1: Application 계층에서 조합 (가장 많이 사용 - 70%)

**사용 시기**:
- 여러 애그리게이트의 정보를 조합해야 할 때
- 비즈니스 로직이 복잡하지 않을 때
- 명확한 유즈케이스 경계가 있을 때

```java
// ✅ 권장: UseCase → UseCase 호출
@UseCase
@RequiredArgsConstructor
public class CreateOrderService implements CreateOrderUseCase {

    // 다른 유즈케이스 의존 (권장)
    private final GetProductUseCase getProductUseCase;
    private final GetUserUseCase getUserUseCase;
    private final OrderRepositoryPort orderRepository;

    @Transactional
    public OrderResponse createOrder(CreateOrderCommand command) {
        // 1. 다른 애그리게이트 정보 조회 (각 유즈케이스 통해)
        ProductResponse product = getProductUseCase.getProduct(command.productId());
        UserResponse user = getUserUseCase.getUser(command.userId());

        // 2. 도메인 검증
        validateOrderCreation(product, user);

        // 3. 주문 생성 (필요한 정보만 전달)
        Order order = Order.create(
            new UserId(user.id()),
            new ProductInfo(
                new ProductId(product.id()),
                new Money(product.price()),
                product.name()
            ),
            command.quantity()
        );

        // 4. 저장
        Order savedOrder = orderRepository.save(order);

        // 5. 도메인 이벤트 발행 (필요시)
        publishOrderCreatedEvent(savedOrder);

        return OrderResponse.from(savedOrder);
    }

    private void validateOrderCreation(ProductResponse product, UserResponse user) {
        if (!product.isAvailable()) {
            throw new ProductNotAvailableException(product.id());
        }
        if (!user.isActive()) {
            throw new UserNotActiveException(user.id());
        }
    }
}

// ProductInfo는 Order 애그리게이트 내부의 Value Object
public record ProductInfo(
    ProductId productId,
    Money price,
    String productName  // 스냅샷 저장
) {
    // 주문 시점의 상품 정보를 보존
}
```

### 패턴 2: 도메인 서비스 활용 (복잡한 비즈니스 로직 - 20%)

**사용 시기**:
- 여러 애그리게이트에 걸친 복잡한 비즈니스 규칙이 있을 때
- 도메인 전문가가 명시적으로 언급하는 비즈니스 프로세스
- 계산이나 검증 로직이 복잡할 때

```java
// 도메인 서비스 (domain/order/service/)
@DomainService
public class OrderPricingService {

    // 복잡한 가격 계산 로직
    public OrderPrice calculateOrderPrice(
            Order order,
            Product product,
            Customer customer,
            List<Coupon> applicableCoupons) {

        // 기본 가격 계산
        Money basePrice = product.getPrice().multiply(order.getQuantity());

        // 고객 등급별 할인
        Money customerDiscount = calculateCustomerDiscount(customer, basePrice);

        // 쿠폰 할인 (중복 적용 규칙 처리)
        Money couponDiscount = calculateCouponDiscount(applicableCoupons, basePrice);

        // 배송비 계산
        Money shippingFee = calculateShippingFee(order, customer);

        return new OrderPrice(
            basePrice,
            customerDiscount,
            couponDiscount,
            shippingFee,
            calculateFinalPrice(basePrice, customerDiscount, couponDiscount, shippingFee)
        );
    }

    // 재고 검증 로직
    public boolean canFulfillOrder(Order order, Product product, Inventory inventory) {
        // 복잡한 재고 확인 로직
        int requiredQuantity = order.getQuantity();
        int availableQuantity = inventory.getAvailableQuantity(product.getId());
        int reservedQuantity = inventory.getReservedQuantity(product.getId());

        return (availableQuantity - reservedQuantity) >= requiredQuantity;
    }
}

// Application 계층에서 도메인 서비스 사용
@UseCase
@RequiredArgsConstructor
public class CreateOrderService implements CreateOrderUseCase {

    private final OrderPricingService orderPricingService;  // 도메인 서비스
    private final GetProductUseCase getProductUseCase;
    private final GetCustomerUseCase getCustomerUseCase;
    private final GetCouponUseCase getCouponUseCase;
    private final OrderRepositoryPort orderRepository;

    @Transactional
    public OrderResponse createOrder(CreateOrderCommand command) {
        // 필요한 애그리게이트들 조회
        Product product = getProductUseCase.getProduct(command.productId()).toDomain();
        Customer customer = getCustomerUseCase.getCustomer(command.customerId()).toDomain();
        List<Coupon> coupons = getCouponUseCase.getCoupons(command.couponIds());

        // 도메인 서비스를 통한 가격 계산
        OrderPrice orderPrice = orderPricingService.calculateOrderPrice(
            order, product, customer, coupons
        );

        // 주문 생성
        Order order = Order.create(command, orderPrice);

        return OrderResponse.from(orderRepository.save(order));
    }
}
```

### 패턴 3: 이벤트 기반 통신 (느슨한 결합 - 10%)

**사용 시기**:
- 애그리게이트 간 느슨한 결합이 필요할 때
- 비동기 처리가 가능한 경우
- 최종 일관성이 허용되는 경우

```java
// 주문 생성 후 재고 차감을 이벤트로 처리
@UseCase
@RequiredArgsConstructor
public class CreateOrderService implements CreateOrderUseCase {

    private final OrderRepositoryPort orderRepository;
    private final EventPublisherPort eventPublisher;

    @Transactional
    public OrderResponse createOrder(CreateOrderCommand command) {
        // 주문 생성
        Order order = Order.create(command);
        Order savedOrder = orderRepository.save(order);

        // 이벤트 발행 (재고 차감은 별도 프로세스에서)
        eventPublisher.publish(new OrderCreatedEvent(
            savedOrder.getId(),
            savedOrder.getProductId(),
            savedOrder.getQuantity(),
            LocalDateTime.now()
        ));

        return OrderResponse.from(savedOrder);
    }
}

// 재고 서비스에서 이벤트 처리
@EventHandler
@RequiredArgsConstructor
public class InventoryEventHandler {

    private final DeductInventoryUseCase deductInventoryUseCase;

    @EventListener
    @Async
    public void handleOrderCreated(OrderCreatedEvent event) {
        try {
            deductInventoryUseCase.deduct(
                new DeductInventoryCommand(
                    event.productId(),
                    event.quantity()
                )
            );
        } catch (InsufficientInventoryException e) {
            // 보상 트랜잭션 처리
            publishOrderCancellationEvent(event.orderId());
        }
    }
}
```

## 계층 간 호출 규칙

### 1. Application 계층 내부 호출

```java
// ✅ 권장: UseCase → UseCase
@UseCase
public class TransferMoneyService implements TransferMoneyUseCase {
    private final GetAccountUseCase getAccountUseCase;  // 다른 UseCase 호출
    private final UpdateAccountUseCase updateAccountUseCase;

    public void transfer(TransferCommand command) {
        AccountResponse from = getAccountUseCase.getAccount(command.fromAccountId());
        AccountResponse to = getAccountUseCase.getAccount(command.toAccountId());
        // ...
    }
}

// ⚠️ 상황에 따라: UseCase → Port (직접 호출)
@UseCase
public class CreateOrderService implements CreateOrderUseCase {
    private final ProductRepositoryPort productRepository;  // 직접 Port 호출

    public OrderResponse createOrder(CreateOrderCommand command) {
        // 단순 조회만 필요한 경우 Port 직접 호출도 가능
        Optional<Product> product = productRepository.findById(command.productId());
        // ...
    }
}

// ❌ 금지: 순환 참조
@UseCase
public class AService {
    private final BUseCase bUseCase;  // A → B
}

@UseCase
public class BService {
    private final AUseCase aUseCase;  // B → A (순환 참조!)
}
```

### 2. 호출 방식 선택 기준

| 상황 | UseCase 호출 | Port 직접 호출 |
|-----|------------|--------------|
| 비즈니스 로직이 있는 경우 | ✅ 권장 | ❌ |
| 단순 CRUD | ⚠️ 가능 | ✅ 권장 |
| 트랜잭션 관리 필요 | ✅ 권장 | ⚠️ 주의 |
| 이벤트 발행 필요 | ✅ 권장 | ❌ |
| 권한 체크 필요 | ✅ 권장 | ❌ |

### 3. 트랜잭션 경계 관리

```java
// 각 UseCase는 독립적인 트랜잭션
@UseCase
public class OrderProcessService {
    private final CreateOrderUseCase createOrderUseCase;
    private final PaymentUseCase paymentUseCase;
    private final NotificationUseCase notificationUseCase;

    // Saga 패턴으로 처리 (각각 별도 트랜잭션)
    public void processOrder(OrderProcessCommand command) {
        try {
            // 트랜잭션 1: 주문 생성
            OrderResponse order = createOrderUseCase.create(command.toOrderCommand());

            try {
                // 트랜잭션 2: 결제 처리
                PaymentResponse payment = paymentUseCase.process(command.toPaymentCommand());

                // 트랜잭션 3: 알림 발송 (실패해도 롤백 안함)
                notificationUseCase.send(new NotificationCommand(order, payment));

            } catch (PaymentException e) {
                // 보상 트랜잭션: 주문 취소
                cancelOrderUseCase.cancel(order.id());
                throw e;
            }
        } catch (Exception e) {
            // 전체 실패 처리
            log.error("Order processing failed", e);
            throw new OrderProcessingException(e);
        }
    }
}
```

## 데이터 일관성 전략

### 즉시 일관성 (Same Transaction)
```java
@UseCase
@Transactional  // 하나의 트랜잭션
public class UpdateOrderService {
    private final OrderRepositoryPort orderRepository;
    private final OrderItemRepositoryPort orderItemRepository;

    public void updateOrder(UpdateOrderCommand command) {
        // 같은 트랜잭션 내에서 Order와 OrderItem 모두 수정
        Order order = orderRepository.findById(command.orderId()).orElseThrow();
        order.update(command);
        orderRepository.save(order);

        // OrderItem도 같은 트랜잭션에서 처리
        List<OrderItem> items = orderItemRepository.findByOrderId(command.orderId());
        items.forEach(item -> item.updatePrice(command.newPrice()));
        orderItemRepository.saveAll(items);
    }
}
```

### 최종 일관성 (Eventually Consistent)
```java
@UseCase
public class CreateOrderService {
    private final OrderRepositoryPort orderRepository;
    private final EventPublisherPort eventPublisher;

    @Transactional
    public OrderResponse createOrder(CreateOrderCommand command) {
        // 주문만 생성
        Order order = Order.create(command);
        Order saved = orderRepository.save(order);

        // 이벤트로 다른 애그리게이트 업데이트 트리거
        eventPublisher.publish(new OrderCreatedEvent(saved));

        return OrderResponse.from(saved);
    }
}

// 별도 서비스에서 이벤트 처리
@EventHandler
public class InventoryEventHandler {
    @EventListener
    @Transactional(propagation = Propagation.REQUIRES_NEW)  // 별도 트랜잭션
    public void on(OrderCreatedEvent event) {
        // 비동기로 재고 차감
        inventory.deduct(event.productId(), event.quantity());
    }
}
```

## 실무 권장 사항

### 1. 기본 전략
- **UseCase → UseCase 호출을 기본**으로 사용
- 단순 조회는 Port 직접 호출 허용
- 복잡한 도메인 로직은 도메인 서비스 활용

### 2. 애그리게이트 설계
```java
// ✅ 좋은 예: 필요한 정보만 스냅샷으로 저장
public class Order {
    private OrderId id;
    private UserId userId;
    private ProductInfo productInfo;  // 주문 시점의 상품 정보 스냅샷
    private Money totalAmount;
    private OrderStatus status;
}

// ❌ 나쁜 예: 다른 애그리게이트 직접 참조
public class Order {
    private OrderId id;
    private User user;  // 다른 애그리게이트 직접 참조
    private Product product;  // 다른 애그리게이트 직접 참조
}
```

### 3. 성능 고려사항
```java
// N+1 문제 방지: ID 리스트로 한번에 조회
@UseCase
public class GetOrderDetailsService {

    public List<OrderDetailResponse> getOrderDetails(List<OrderId> orderIds) {
        // 1. 주문 목록 조회
        List<Order> orders = orderRepository.findByIds(orderIds);

        // 2. 필요한 ID 수집
        Set<ProductId> productIds = orders.stream()
            .map(Order::getProductId)
            .collect(Collectors.toSet());

        Set<UserId> userIds = orders.stream()
            .map(Order::getUserId)
            .collect(Collectors.toSet());

        // 3. 한번에 조회 (N+1 방지)
        Map<ProductId, Product> products = productRepository.findByIds(productIds);
        Map<UserId, User> users = userRepository.findByIds(userIds);

        // 4. 조합
        return orders.stream()
            .map(order -> OrderDetailResponse.of(
                order,
                products.get(order.getProductId()),
                users.get(order.getUserId())
            ))
            .toList();
    }
}
```

## 안티패턴

### 피해야 할 패턴
```java
// ❌ 도메인에서 다른 애그리게이트 Repository 호출
public class Order {
    public void validateProduct(ProductRepository productRepository) {
        Product product = productRepository.findById(this.productId);
        // 도메인이 인프라에 의존하게 됨
    }
}

// ❌ 애그리게이트 간 직접 참조
@Entity
public class Order {
    @ManyToOne
    private Product product;  // 다른 애그리게이트 직접 참조
}

// ❌ 하나의 트랜잭션에서 여러 애그리게이트 수정
@Transactional
public void processOrder() {
    order.update();
    product.decreaseStock();  // 다른 애그리게이트
    user.updateLastOrderDate();  // 또 다른 애그리게이트
    // 트랜잭션 범위가 너무 큼
}

// ❌ 순환 참조
public class OrderService {
    @Autowired
    private ProductService productService;
}

public class ProductService {
    @Autowired
    private OrderService orderService;  // 순환 참조!
}
```

## 검증 체크리스트

### 설계 검증
- [ ] 애그리게이트가 ID로만 다른 애그리게이트를 참조하는가?
- [ ] 하나의 트랜잭션에서 하나의 애그리게이트만 수정하는가?
- [ ] 도메인 계층이 다른 계층에 의존하지 않는가?

### 구현 검증
- [ ] UseCase 간 호출이 순환 참조 없이 구성되었는가?
- [ ] 복잡한 비즈니스 로직이 도메인 서비스로 분리되었는가?
- [ ] 트랜잭션 경계가 명확한가?

### 성능 검증
- [ ] N+1 쿼리 문제가 없는가?
- [ ] 불필요한 애그리게이트 로딩이 없는가?
- [ ] 적절한 수준의 최종 일관성을 허용하는가?
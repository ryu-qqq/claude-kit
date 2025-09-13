# Java 헥사고날 아키텍처 컨벤션

## 패키지 구조 (필수 준수)

```
com.company.project/
├── domain/                     # 핵심 비즈니스 로직 (Spring 의존성 절대 금지)
│   ├── [aggregate]/           # 애그리게이트별 패키지
│   │   ├── [Aggregate].java   # 애그리게이트 루트
│   │   ├── [ValueObject].java # 값 객체들
│   │   ├── [DomainService].java # 도메인 서비스
│   │   ├── exception/         # 도메인 특화 예외
│   │   │   └── [Domain]Exception.java
│   │   └── event/
│   │       └── [DomainEvent].java
│   └── shared/                # 공통 도메인 요소
│       ├── exception/
│       │   ├── DomainException.java  # 기본 도메인 예외
│       │   └── ValidationException.java
│       ├── DomainEvent.java
│       └── ValueObject.java
│
├── application/               # 유즈케이스 계층
│   ├── port/
│   │   ├── in/               # 인바운드 포트 (진입점)
│   │   │   └── [Action]UseCase.java
│   │   └── out/              # 아웃바운드 포트 (외부 의존)
│   │       └── [Resource]Port.java
│   ├── service/              # 유즈케이스 구현
│   │   └── [Action]Service.java
│   ├── dto/                  # 유즈케이스별 DTO
│   │   ├── [usecase]/
│   │   │   ├── [Action]Command.java
│   │   │   └── [Action]Response.java
│   │   └── common/
│   │       ├── PageRequest.java
│   │       └── PageResponse.java
│   └── exception/
│       └── ApplicationException.java  # 애플리케이션 예외
│
├── adapter/                  # 어댑터 계층
│   ├── in/                  # 인바운드 어댑터
│   │   └── web/
│   │       ├── [Domain]Controller.java
│   │       ├── dto/         # 컨트롤러 전용 DTO
│   │       │   └── [Domain]ApiResponse.java
│   │       └── exception/
│   │           └── GlobalExceptionHandler.java
│   └── out/                 # 아웃바운드 어댑터
│       └── persistence/
│           └── [Domain]JpaAdapter.java
│
└── configuration/           # Spring 설정
    └── [Context]Config.java
```

## 네이밍 규칙 (엄격 적용)

### 1. 인바운드 포트 (UseCase)
```java
// 패턴: [동작][대상]UseCase
public interface CreateUserUseCase { }
public interface GetUserUseCase { }
public interface UpdateUserProfileUseCase { }
public interface DeleteUserUseCase { }

// CQRS 적용시
public interface [Action][Domain]CommandUseCase { }
public interface [Query][Domain]QueryUseCase { }
```

### 2. 아웃바운드 포트 (Port)
```java
// 패턴: [리소스명]Port
public interface UserRepositoryPort { }      // 저장소
public interface NotificationPort { }        // 알림
public interface EventPublisherPort { }      // 이벤트
public interface PaymentGatewayPort { }      // 외부 시스템

// 절대 금지: ~Repository (Port 없이)
```

### 3. 유즈케이스 구현 (Service)
```java
// 패턴: [동작][대상]Service implements [동작][대상]UseCase
@UseCase  // 커스텀 애노테이션 필수
public class CreateUserService implements CreateUserUseCase { }
public class GetUserService implements GetUserUseCase { }
```

### 4. 어댑터 구현
```java
// 인바운드: [도메인]Controller
@RestController
public class UserController { }

// 아웃바운드: [도메인][기술]Adapter
@PersistenceAdapter
public class UserJpaAdapter implements UserRepositoryPort { }
public class UserMongoAdapter implements UserRepositoryPort { }
public class EmailNotificationAdapter implements NotificationPort { }
```

### 5. 커맨드/쿼리 객체
```java
// Command: 상태 변경 요청 (불변 객체)
public class CreateUserCommand {
    private final String email;
    private final String name;
    // 생성자, getter만 (no setter)
}

// Query: 조회 요청 (불변 객체)
public class GetUserQuery {
    private final String userId;
    // 생성자, getter만
}

// Response: 응답 (불변 객체)
public class UserResponse {
    private final String id;
    private final String email;
    // 생성자, getter만
}
```

## 의존성 규칙 (위반시 컴파일 에러)

### ✅ 허용된 의존성 방향
```
Adapter → Application → Domain
   ↓          ↓           X
Spring    Port 정의    순수 Java
```

### ❌ 절대 금지 사항
```java
// Domain 계층에서 금지
import org.springframework.*;  // Spring 의존성 금지
import javax.persistence.*;    // JPA 의존성 금지
import lombok.*;               // Lombok 금지

// Application 계층에서 금지
import org.springframework.web.*;  // Web 관련 금지
import javax.persistence.*;        // JPA 금지
```

## 커스텀 애노테이션 (필수 정의)

```java
// UseCase.java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Service
@Transactional
public @interface UseCase { }

// PersistenceAdapter.java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Component
public @interface PersistenceAdapter { }

// DomainService.java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface DomainService { }
```

## 생성자 주입 규칙 (Lombok 금지)

```java
// ❌ 금지
@RequiredArgsConstructor  // Lombok 금지
@AllArgsConstructor      // Lombok 금지
@Autowired               // 필드 주입 금지
private UserService userService;

// ✅ 필수
public class CreateUserService implements CreateUserUseCase {
    private final UserRepositoryPort userRepository;
    private final NotificationPort notificationPort;

    public CreateUserService(
            UserRepositoryPort userRepository,
            NotificationPort notificationPort) {
        this.userRepository = userRepository;
        this.notificationPort = notificationPort;
    }
}
```

## 트랜잭션 경계

```java
// ✅ 메서드 레벨 트랜잭션 (필수)
@UseCase
public class CreateUserService implements CreateUserUseCase {
    @Transactional  // 메서드 단위로 명시
    public UserResponse createUser(CreateUserCommand command) {
        // 트랜잭션 범위 명확
    }

    // 트랜잭션 불필요한 메서드
    public void validateEmail(String email) {
        // 검증만 수행
    }
}

// 읽기 전용 트랜잭션
@UseCase
public class GetUserService implements GetUserUseCase {
    @Transactional(readOnly = true)
    public UserResponse getUser(GetUserQuery query) {
        // 읽기 최적화
    }
}

// ❌ 클래스 레벨 트랜잭션 금지
@UseCase
@Transactional  // 금지 - 불필요한 오버헤드
public class UserService { }
```

## 도메인 이벤트 처리

```java
// 도메인 객체에서 이벤트 발생
public class User {
    private final List<DomainEvent> domainEvents = new ArrayList<>();

    public User(Email email, UserName name) {
        // 생성 로직
        addDomainEvent(new UserCreatedEvent(this.id));
    }
}

// 유즈케이스에서 이벤트 발행
@UseCase
public class CreateUserService {
    private final EventPublisherPort eventPublisher;

    public UserResponse createUser(CreateUserCommand command) {
        User user = new User(...);
        userRepository.save(user);

        // 도메인 이벤트 발행
        user.getDomainEvents().forEach(eventPublisher::publish);
        user.clearDomainEvents();
    }
}
```

## Java 21 기능 활용 (필수)

### Java 버전 명시
```xml
<!-- pom.xml -->
<properties>
    <java.version>21</java.version>
</properties>

<!-- build.gradle -->
java {
    sourceCompatibility = JavaVersion.VERSION_21
    targetCompatibility = JavaVersion.VERSION_21
}
```

### Record 사용 규칙

```java
// ✅ Value Objects - Record 필수
public record Email(String value) {
    public Email {
        if (value == null || !value.matches("^[^@]+@[^@]+\\.[^@]+$")) {
            throw new IllegalArgumentException("Invalid email");
        }
    }
}

public record UserId(String value) {
    public static UserId generate() {
        return new UserId(UUID.randomUUID().toString());
    }
}

// ✅ Commands/Queries - Record 필수
public record CreateUserCommand(
    Email email,
    String name
) implements Command {
    public CreateUserCommand {
        Objects.requireNonNull(email);
        Objects.requireNonNull(name);
    }
}

// ✅ Events - Record 필수
public record UserCreatedEvent(
    UserId userId,
    Email email,
    LocalDateTime occurredAt
) implements DomainEvent {}

// ❌ Entities - Class 사용 (복잡한 비즈니스 로직)
public final class User { // Record 대신 Class
    private final UserId id;
    private final Email email;
    // ...
}
```

### 불변 객체 업데이트 패턴

```java
// Withers Pattern (권장)
public final class User {
    private final UserId id;
    private final Email email;
    private final UserProfile profile;

    // 단일 필드 업데이트
    public User withEmail(Email newEmail) {
        validateEmailChange(newEmail);
        return new User(this.id, newEmail, this.profile);
    }

    public User withProfile(UserProfile newProfile) {
        return new User(this.id, this.email, newProfile);
    }

    // 복잡한 업데이트는 Builder 사용
    public static Builder toBuilder(User user) {
        return new Builder(user);
    }
}
```

### 팩토리 패턴 사용

```java
// 간단한 생성: Static Factory Method
public final class User {
    public static User create(Email email, String name) {
        return new User(
            UserId.generate(),
            email,
            new UserProfile(name),
            LocalDateTime.now()
        );
    }
}

// 복잡한 생성: Factory Class
@Component
public class UserFactory {
    private final UserRepository userRepository;

    public User createUser(CreateUserCommand command) {
        validateEmailUniqueness(command.email());
        return User.create(command.email(), command.name());
    }
}
```

### Pattern Matching 활용

```java
// Event 처리
public void handle(DomainEvent event) {
    switch (event) {
        case UserCreatedEvent(var userId, var email, var occurredAt) ->
            sendWelcomeEmail(email);
        case UserDeletedEvent(var userId, var occurredAt) ->
            cleanupUserData(userId);
        default -> logger.warn("Unknown event: {}", event);
    }
}
```

### Sealed Classes 활용

```java
// 도메인 타입 제한
public sealed interface PaymentMethod
    permits CreditCard, BankTransfer, DigitalWallet {
    Money getAmount();
}

public final class CreditCard implements PaymentMethod { }
public final class BankTransfer implements PaymentMethod { }
public final class DigitalWallet implements PaymentMethod { }
```

### Virtual Threads 활용

```java
@UseCase
public class CreateUserService {
    private static final Executor VIRTUAL_EXECUTOR =
        Executors.newVirtualThreadPerTaskExecutor();

    public CompletableFuture<UserResponse> createUser(CreateUserCommand command) {
        return CompletableFuture.supplyAsync(() -> {
            // Virtual Thread에서 실행
            User user = userFactory.createUser(command);
            userRepository.save(user);
            return UserResponse.from(user);
        }, VIRTUAL_EXECUTOR);
    }
}
```

## 예외 처리 전략

### 예외 계층 구조
```java
// 기본 도메인 예외 (domain/shared/exception/)
public abstract class DomainException extends RuntimeException {
    private final String userMessage;
    private final String errorCode;

    protected DomainException(String message, String userMessage, String errorCode) {
        super(message);  // 내부 로그용 상세 메시지
        this.userMessage = userMessage;  // 사용자에게 보여줄 안전한 메시지
        this.errorCode = errorCode;
    }

    public String getUserMessage() {
        return userMessage != null ? userMessage : "처리 중 오류가 발생했습니다.";
    }
}

// 도메인 특화 예외 - 도메인 클래스 내부에 정의
public final class Order {
    // ✅ 도메인 특화 예외는 내부 클래스로
    public static class InvalidOrderStateException extends DomainException {
        public InvalidOrderStateException(OrderStatus current, OrderStatus expected) {
            super(
                String.format("Invalid state transition: %s -> %s", current, expected),  // 로그
                "주문 상태를 변경할 수 없습니다.",  // 사용자 메시지
                "ORDER_INVALID_STATE"  // 에러 코드
            );
        }
    }
}

// 공통 예외는 shared에 별도 클래스로
public class ValidationException extends DomainException {
    public ValidationException(String field, String value) {
        super(
            String.format("Validation failed: field=%s, value=%s", field, value),
            "입력값이 올바르지 않습니다.",
            "VALIDATION_ERROR"
        );
    }
}
```

### 예외 처리 원칙
```java
// Application 계층 - 예외 변환
@UseCase
public class CreateOrderService {
    @Transactional
    public OrderResponse createOrder(CreateOrderCommand command) {
        try {
            // 도메인 로직 실행
            Order order = orderFactory.create(command);
            orderRepository.save(order);
            return OrderResponse.from(order);

        } catch (DomainException e) {
            // 도메인 예외는 그대로 전파
            log.error("Domain error: {}", e.getMessage(), e);
            throw e;
        } catch (DataAccessException e) {
            // 기술적 예외는 애플리케이션 예외로 변환
            log.error("Database error while creating order", e);
            throw new ApplicationException("주문 생성 실패", "ORDER_CREATION_FAILED", e);
        }
    }
}

// Adapter 계층 - 예외 응답 변환
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(DomainException.class)
    public ResponseEntity<ErrorResponse> handleDomainException(DomainException e) {
        // 내부 로그 - 상세 정보
        log.error("Domain exception: code={}, message={}",
            e.getErrorCode(), e.getMessage(), e);

        // 외부 응답 - 안전한 메시지
        return ResponseEntity.badRequest()
            .body(new ErrorResponse(
                e.getErrorCode(),
                e.getUserMessage(),
                LocalDateTime.now()
            ));
    }
}
```

## 중첩 클래스 사용 규칙

### 중첩 클래스 사용 기준
```java
// ✅ 중첩 클래스로 정의하는 경우

// 1. 컨트롤러 전용 Request/Response DTO
@RestController
public class UserController {
    // 해당 컨트롤러에서만 사용되는 DTO는 내부에 정의
    public record CreateUserRequest(String email, String name) {}

    public record UserApiResponse(
        String id,
        String email,
        LocalDateTime createdAt
    ) {
        public static UserApiResponse from(UserResponse response) {
            return new UserApiResponse(
                response.userId(),
                response.email(),
                response.createdAt()
            );
        }
    }
}

// 2. 도메인 특화 예외
public final class Account {
    public static class InsufficientBalanceException extends DomainException {
        // 해당 도메인에서만 발생하는 예외
    }
}

// 3. 도메인 내부 Value Object
public final class Order {
    public record OrderLine(
        ProductId productId,
        Quantity quantity,
        Money price
    ) {
        // Order에서만 사용되는 Value Object
    }
}
```

### 별도 클래스로 정의하는 경우
```java
// ❌ 별도 클래스로 정의하는 경우

// 1. 여러 곳에서 재사용되는 DTO
// application/dto/common/
public record PageRequest(int page, int size, String sort) {}
public record PageResponse<T>(List<T> content, int totalPages, long totalElements) {}

// 2. 공통 예외
// domain/shared/exception/
public class ValidationException extends DomainException {}
public class AuthorizationException extends DomainException {}

// 3. 공유되는 Value Object
// domain/shared/
public record Money(BigDecimal amount, Currency currency) {}
public record Email(String value) {}
```

## DTO 구조 및 변환 규칙

### DTO 패키지 구조
```java
// Application 계층 - 유즈케이스별 그룹화
application/
├── dto/
│   ├── user/
│   │   ├── CreateUserCommand.java     // 유즈케이스 입력
│   │   ├── CreateUserResponse.java    // 유즈케이스 출력
│   │   ├── UpdateUserCommand.java
│   │   └── UserResponse.java          // 공통 응답
│   └── common/
│       ├── PageRequest.java           // 페이징 요청
│       └── ErrorDetail.java           // 에러 응답

// Adapter 계층 - API 전용 DTO는 컨트롤러 내부에
adapter/in/web/
└── UserController.java
    ├── CreateUserRequest (inner class)  // API 요청
    └── UserApiResponse (inner class)    // API 응답
```

### DTO 변환 패턴
```java
// 계층 간 변환 체인
// API Request → Command → Domain → Response → API Response

@RestController
public class OrderController {
    private final CreateOrderUseCase createOrderUseCase;

    // API 전용 DTO (내부 클래스)
    public record CreateOrderRequest(
        String productId,
        int quantity,
        String couponCode
    ) {
        // API → Command 변환
        public CreateOrderCommand toCommand() {
            return new CreateOrderCommand(
                new ProductId(productId),
                new Quantity(quantity),
                Optional.ofNullable(couponCode).map(CouponCode::new)
            );
        }
    }

    public record OrderApiResponse(
        String orderId,
        String status,
        BigDecimal totalAmount
    ) {
        // Response → API 변환
        public static OrderApiResponse from(OrderResponse response) {
            return new OrderApiResponse(
                response.orderId().value(),
                response.status().name(),
                response.totalAmount().amount()
            );
        }
    }

    @PostMapping("/orders")
    public ResponseEntity<OrderApiResponse> createOrder(
            @RequestBody CreateOrderRequest request) {

        // 변환 체인: Request → Command → Response → ApiResponse
        CreateOrderCommand command = request.toCommand();
        OrderResponse response = createOrderUseCase.create(command);
        return ResponseEntity.ok(OrderApiResponse.from(response));
    }
}
```

## 객체 생성 규칙

### 생성자 제한
```java
// ✅ 권장: private 생성자 + static factory
public final class User {
    private User(UserId id, Email email) { }

    public static User create(Email email, String name) {
        return new User(UserId.generate(), email);
    }
}

// ❌ 금지: public 생성자 직접 노출
public class User {
    public User(String email) { } // 금지
}
```

## Java 21 Deprecated 메서드 금지 규칙

### ❌ 절대 사용 금지 (Java 21에서 deprecated)

#### 1. Thread 관련 deprecated 메서드
```java
// ❌ 금지 - deprecated in Java 21
Thread.stop()
Thread.suspend()
Thread.resume()
Thread.destroy()

// ✅ 권장 - 현대적 동시성 방식
CompletableFuture.supplyAsync(() -> {
    // Virtual Thread 또는 CompletableFuture 사용
});

// ✅ Virtual Threads 사용 (Java 21+)
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    executor.submit(() -> {
        // Virtual Thread에서 실행
    });
}
```

#### 2. Date/Time 관련 deprecated 메서드
```java
// ❌ 금지 - deprecated
new Date(year, month, day)
Date.getYear()
Date.getMonth()
Date.getDate()
Date.setYear()

// ✅ 권장 - Modern Java Time API
LocalDate.of(2025, 1, 15)
LocalDateTime.now()
ZonedDateTime.now(ZoneId.of("Asia/Seoul"))
```

#### 3. Collections 관련 deprecated 메서드
```java
// ❌ 금지 - deprecated
Vector.elements()
Hashtable.elements()
Dictionary.elements()

// ✅ 권장 - Modern Collections
List.of()
Set.of()
Map.of()
```

#### 4. Security 관련 deprecated 메서드
```java
// ❌ 금지 - deprecated (보안 취약)
Runtime.getRuntime().exec(command)  // 직접 사용 금지

// ✅ 권장 - ProcessBuilder 사용
ProcessBuilder pb = new ProcessBuilder(command);
Process process = pb.start();
```

#### 5. Reflection 관련 deprecated 메서드
```java
// ❌ 금지 - deprecated
Class.newInstance()

// ✅ 권장 - Constructor 사용
Class<?> clazz = User.class;
Constructor<?> constructor = clazz.getConstructor();
Object instance = constructor.newInstance();
```

### 🔍 Deprecated 감지 및 방지

#### 1. Gradle 설정으로 deprecated 사용 금지
```gradle
compileJava {
    options.compilerArgs += [
        '-Xlint:deprecation',
        '-Werror'  // deprecated 사용 시 컴파일 에러
    ]
}

compileTestJava {
    options.compilerArgs += [
        '-Xlint:deprecation',
        '-Werror'
    ]
}
```

#### 2. ArchUnit으로 deprecated 사용 금지 검증
```java
@ArchTest
static final ArchRule no_deprecated_methods_allowed =
    noClasses()
        .should().accessClassesThat()
        .areAnnotatedWith(Deprecated.class)
        .because("Deprecated 클래스/메서드 사용 금지");

@ArchTest
static final ArchRule no_legacy_date_usage =
    noClasses()
        .should().dependOnClassesThat()
        .haveFullyQualifiedName("java.util.Date")
        .because("java.util.Date 대신 java.time API 사용");

@ArchTest
static final ArchRule no_legacy_collections =
    noClasses()
        .should().dependOnClassesThat()
        .haveSimpleNameStartingWith("Vector")
        .or().haveSimpleNameStartingWith("Hashtable")
        .because("Vector, Hashtable 대신 List, Map 사용");
```

#### 3. SpotBugs 규칙으로 deprecated 감지
```xml
<!-- spotbugs-exclude.xml -->
<FindBugsFilter>
    <!-- deprecated 메서드 사용 시 에러 -->
    <Match>
        <Bug pattern="DM_DEFAULT_ENCODING" />
    </Match>
</FindBugsFilter>
```

### 🔄 Migration 가이드

#### Date → LocalDateTime
```java
// ❌ Before (deprecated)
Date date = new Date();
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
String formatted = sdf.format(date);

// ✅ After (Java 21 권장)
LocalDateTime now = LocalDateTime.now();
String formatted = now.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
```

#### Thread 관리 → Virtual Threads
```java
// ❌ Before (deprecated)
Thread thread = new Thread(() -> {
    // work
});
thread.start();
thread.stop(); // deprecated!

// ✅ After (Java 21 Virtual Threads)
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    Future<?> future = executor.submit(() -> {
        // work
    });
    // 자동으로 정리됨
}
```

#### Collections 초기화
```java
// ❌ Before (legacy)
Vector<String> vector = new Vector<>();
Hashtable<String, String> hashtable = new Hashtable<>();

// ✅ After (modern)
List<String> list = new ArrayList<>();
Map<String, String> map = new HashMap<>();

// ✅ 불변 컬렉션 (Java 21)
List<String> immutableList = List.of("a", "b", "c");
Map<String, String> immutableMap = Map.of("key1", "value1", "key2", "value2");
```

### 🚨 IDE 설정으로 deprecated 경고

#### IntelliJ IDEA 설정
```properties
# File → Settings → Editor → Inspections
# Java → Code maturity → Deprecated API usage → Error로 설정
# Java → Probable bugs → @Deprecated annotation → Error로 설정
```

#### VS Code 설정
```json
{
  "java.compile.nullAnalysis.mode": "automatic",
  "java.warnings.deprecation": "error"
}
```

## 검증 체크리스트

### 기본 아키텍처
- [ ] domain 패키지에 Spring 의존성이 없는가?
- [ ] 모든 포트가 인터페이스로 정의되어 있는가?
- [ ] UseCase 네이밍 규칙을 따르는가?
- [ ] Port 네이밍 규칙을 따르는가?
- [ ] 생성자 주입을 사용하는가?
- [ ] Lombok을 사용하지 않는가?
- [ ] Command/Query/Response가 불변 객체인가?
- [ ] 의존성 방향이 올바른가?
- [ ] 커스텀 애노테이션을 사용하는가?

### Java 21 Deprecated 방지
- [ ] Gradle에서 -Xlint:deprecation -Werror 설정했는가?
- [ ] ArchUnit으로 deprecated 사용 검증 규칙을 추가했는가?
- [ ] java.util.Date 대신 java.time API를 사용하는가?
- [ ] Thread deprecated 메서드 대신 Virtual Threads를 사용하는가?
- [ ] Vector, Hashtable 대신 현대적 Collections를 사용하는가?
- [ ] Class.newInstance() 대신 Constructor.newInstance()를 사용하는가?
- [ ] IDE에서 deprecated 사용 시 에러로 설정했는가?

### 트랜잭션 전략
- [ ] 트랜잭션은 메서드 레벨에 적용했는가?
- [ ] 클래스 레벨 @Transactional을 제거했는가?
- [ ] 읽기 전용 메서드는 readOnly=true를 명시했는가?
- [ ] 외부 시스템 호출은 트랜잭션 밖에서 처리하는가?

### 예외 처리
- [ ] 도메인 예외는 DomainException을 상속하는가?
- [ ] 도메인 특화 예외는 해당 도메인 클래스 내부에 정의했는가?
- [ ] 공통 예외는 shared 패키지에 별도로 정의했는가?
- [ ] 예외에 userMessage와 errorCode를 포함하는가?
- [ ] 내부 로그와 외부 메시지를 분리했는가?

### 중첩 클래스 vs 별도 클래스
- [ ] 컨트롤러 전용 DTO는 컨트롤러 내부에 정의했는가?
- [ ] 도메인 특화 예외는 도메인 클래스 내부에 정의했는가?
- [ ] 재사용되는 DTO는 별도 패키지에 정의했는가?
- [ ] 공유 Value Object는 shared 패키지에 정의했는가?

### DTO 구조 및 변환
- [ ] Application 계층 DTO는 유즈케이스별로 그룹화했는가?
- [ ] API 전용 DTO는 컨트롤러 내부에 정의했는가?
- [ ] DTO 변환 메서드(toCommand, from)를 제공하는가?
- [ ] 계층 간 변환 체인이 명확한가?

### Java 21 기능
- [ ] Java 21로 설정되어 있는가?
- [ ] Value Object는 Record로 구현했는가?
- [ ] Command/Query는 Record로 구현했는가?
- [ ] Event는 Record로 구현했는가?
- [ ] Entity는 Class + Withers Pattern을 사용하는가?
- [ ] 복잡한 객체 생성은 Factory를 사용하는가?
- [ ] Pattern Matching을 활용하는가?
- [ ] public 생성자 대신 static factory method를 사용하는가?
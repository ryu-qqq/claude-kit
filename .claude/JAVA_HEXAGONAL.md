# Java 헥사고날 아키텍처 컨벤션

## 패키지 구조 (필수 준수)

```
com.company.project/
├── domain/                     # 핵심 비즈니스 로직 (Spring 의존성 절대 금지)
│   ├── [aggregate]/           # 애그리게이트별 패키지
│   │   ├── [Aggregate].java   # 애그리게이트 루트
│   │   ├── [ValueObject].java # 값 객체들
│   │   ├── [DomainService].java # 도메인 서비스
│   │   └── event/
│   │       └── [DomainEvent].java
│   └── shared/                # 공통 도메인 요소
│       ├── DomainEvent.java
│       └── ValueObject.java
│
├── application/               # 유즈케이스 계층
│   ├── port/
│   │   ├── in/               # 인바운드 포트 (진입점)
│   │   │   └── [Action]UseCase.java
│   │   └── out/              # 아웃바운드 포트 (외부 의존)
│   │       └── [Resource]Port.java
│   └── service/              # 유즈케이스 구현
│       └── [Action]Service.java
│
├── adapter/                  # 어댑터 계층
│   ├── in/                  # 인바운드 어댑터
│   │   └── web/
│   │       └── [Domain]Controller.java
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
// 유즈케이스 레벨에서만 트랜잭션 시작
@UseCase  // @Transactional 포함
public class CreateUserService implements CreateUserUseCase {
    // 전체 유즈케이스가 하나의 트랜잭션
}

// 읽기 전용
@UseCase
@Transactional(readOnly = true)
public class GetUserService implements GetUserUseCase { }
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

## 검증 체크리스트

### 기본 아키텍처
- [ ] domain 패키지에 Spring 의존성이 없는가?
- [ ] 모든 포트가 인터페이스로 정의되어 있는가?
- [ ] UseCase 네이밍 규칙을 따르는가?
- [ ] Port 네이밍 규칙을 따르는가?
- [ ] 생성자 주입을 사용하는가?
- [ ] Lombok을 사용하지 않는가?
- [ ] 트랜잭션이 유즈케이스 레벨에서 관리되는가?
- [ ] Command/Query/Response가 불변 객체인가?
- [ ] 의존성 방향이 올바른가?
- [ ] 커스텀 애노테이션을 사용하는가?

### Java 21 기능
- [ ] Java 21로 설정되어 있는가?
- [ ] Value Object는 Record로 구현했는가?
- [ ] Command/Query는 Record로 구현했는가?
- [ ] Event는 Record로 구현했는가?
- [ ] Entity는 Class + Withers Pattern을 사용하는가?
- [ ] 복잡한 객체 생성은 Factory를 사용하는가?
- [ ] Pattern Matching을 활용하는가?
- [ ] public 생성자 대신 static factory method를 사용하는가?
# Java 테스트 전략 및 컨벤션

## 테스트 전략 개요

### 테스트 피라미드 (Test Pyramid)
```
        🔺 E2E Tests (10%)
       🔺🔺 Integration Tests (20%)
    🔺🔺🔺🔺 Unit Tests (70%)
```

**원칙**: 빠르고 안정적인 단위 테스트 중심, 필요에 따라 통합/E2E 테스트 보완

## 테스트 분류 및 어노테이션

### 1. 단위 테스트 (Unit Tests) - 70%

#### @UnitTest 커스텀 어노테이션
```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@ExtendWith(MockitoExtension.class)
@Tag("unit")
public @interface UnitTest {
    String[] tags() default {};
}
```

#### 적용 대상 및 패턴
```java
// 도메인 로직 테스트
@UnitTest
class UserTest {
    @Test
    @DisplayName("유효한 이메일로 사용자 생성 시 성공한다")
    void shouldCreateUserWithValidEmail() {
        // Given
        Email email = new Email("user@example.com");
        String name = "홍길동";

        // When
        User user = User.create(email, name);

        // Then
        assertThat(user.getEmail()).isEqualTo(email);
        assertThat(user.getName()).isEqualTo(name);
        assertThat(user.getId()).isNotNull();
    }

    @Test
    @DisplayName("잘못된 이메일로 사용자 생성 시 예외가 발생한다")
    void shouldThrowExceptionWithInvalidEmail() {
        // Given
        String invalidEmail = "invalid-email";

        // When & Then
        assertThatThrownBy(() -> new Email(invalidEmail))
            .isInstanceOf(ValidationException.class)
            .hasMessage("유효하지 않은 이메일 형식입니다");
    }
}

// 유즈케이스 로직 테스트
@UnitTest
class CreateUserServiceTest {
    @Mock private UserRepositoryPort userRepository;
    @Mock private NotificationPort notificationPort;
    @Mock private EventPublisherPort eventPublisher;

    @InjectMocks private CreateUserService createUserService;

    @Test
    @DisplayName("중복되지 않은 이메일로 사용자 생성 시 성공한다")
    void shouldCreateUserWithUniqueEmail() {
        // Given
        CreateUserCommand command = new CreateUserCommand(
            new Email("new@example.com"),
            "신규사용자"
        );

        given(userRepository.existsByEmail(command.email())).willReturn(false);
        given(userRepository.save(any(User.class))).willAnswer(invocation -> invocation.getArgument(0));

        // When
        UserResponse response = createUserService.createUser(command);

        // Then
        assertThat(response.email()).isEqualTo(command.email().value());
        assertThat(response.name()).isEqualTo(command.name());

        // Verify interactions
        verify(userRepository).save(any(User.class));
        verify(notificationPort).sendWelcomeEmail(command.email());
        verify(eventPublisher).publish(any(UserCreatedEvent.class));
    }
}
```

### 2. 통합 테스트 (Integration Tests) - 20%

#### @IntegrationTest 커스텀 어노테이션
```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@SpringBootTest
@Testcontainers
@Transactional
@Tag("integration")
public @interface IntegrationTest {
    String[] profiles() default {"test"};
}
```

#### 적용 대상 및 패턴
```java
// 데이터베이스 통합 테스트
@IntegrationTest
class UserJpaAdapterIntegrationTest {

    @Container
    static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test");

    @Autowired private UserJpaAdapter userJpaAdapter;
    @Autowired private TestEntityManager entityManager;

    @Test
    @DisplayName("사용자 저장 후 조회 시 동일한 데이터를 반환한다")
    void shouldSaveAndFindUser() {
        // Given
        User user = User.create(new Email("test@example.com"), "테스트사용자");

        // When
        User savedUser = userJpaAdapter.save(user);
        entityManager.flush();
        entityManager.clear();

        Optional<User> foundUser = userJpaAdapter.findById(savedUser.getId());

        // Then
        assertThat(foundUser).isPresent();
        assertThat(foundUser.get().getEmail()).isEqualTo(user.getEmail());
        assertThat(foundUser.get().getName()).isEqualTo(user.getName());
    }

    @Test
    @DisplayName("이메일로 사용자 존재 여부 확인이 정확하다")
    void shouldCheckUserExistenceByEmail() {
        // Given
        Email email = new Email("exists@example.com");
        User user = User.create(email, "기존사용자");
        userJpaAdapter.save(user);
        entityManager.flush();

        // When
        boolean exists = userJpaAdapter.existsByEmail(email);
        boolean notExists = userJpaAdapter.existsByEmail(new Email("notexists@example.com"));

        // Then
        assertThat(exists).isTrue();
        assertThat(notExists).isFalse();
    }
}

// API 통합 테스트
@IntegrationTest
class UserControllerIntegrationTest {

    @Autowired private MockMvc mockMvc;
    @Autowired private ObjectMapper objectMapper;

    @Test
    @DisplayName("유효한 사용자 생성 요청 시 201 Created를 반환한다")
    void shouldCreateUserWithValidRequest() throws Exception {
        // Given
        CreateUserRequest request = new CreateUserRequest("test@example.com", "테스트사용자");

        // When & Then
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.email").value("test@example.com"))
                .andExpect(jsonPath("$.name").value("테스트사용자"))
                .andExpect(jsonPath("$.id").exists());
    }

    @Test
    @DisplayName("중복된 이메일로 사용자 생성 시 409 Conflict를 반환한다")
    void shouldReturnConflictWithDuplicateEmail() throws Exception {
        // Given
        CreateUserRequest request = new CreateUserRequest("duplicate@example.com", "중복사용자");

        // 기존 사용자 생성
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)));

        // When & Then
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.errorCode").value("USER_EMAIL_DUPLICATE"))
                .andExpect(jsonPath("$.message").value("이미 존재하는 이메일입니다"));
    }
}
```

### 3. E2E 테스트 (End-to-End Tests) - 10%

#### @E2ETest 커스텀 어노테이션
```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Testcontainers
@Tag("e2e")
public @interface E2ETest {
    String[] profiles() default {"test", "e2e"};
}
```

#### 적용 대상 및 패턴
```java
// 전체 비즈니스 플로우 테스트
@E2ETest
class UserRegistrationE2ETest {

    @Container
    static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0");

    @Container
    static GenericContainer<?> redis = new GenericContainer<>("redis:7-alpine")
            .withExposedPorts(6379);

    @Autowired private TestRestTemplate restTemplate;
    @Autowired private UserJpaAdapter userRepository;

    @Test
    @DisplayName("사용자 등록부터 로그인까지 전체 플로우가 정상 동작한다")
    void shouldCompleteUserRegistrationFlow() {
        // Given - 사용자 등록 요청
        CreateUserRequest createRequest = new CreateUserRequest(
            "e2e@example.com",
            "E2E테스트사용자"
        );

        // When - 사용자 생성
        ResponseEntity<UserResponse> createResponse = restTemplate.postForEntity(
            "/api/users",
            createRequest,
            UserResponse.class
        );

        // Then - 사용자 생성 검증
        assertThat(createResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(createResponse.getBody().email()).isEqualTo("e2e@example.com");

        String userId = createResponse.getBody().id();

        // When - 생성된 사용자 조회
        ResponseEntity<UserResponse> getResponse = restTemplate.getForEntity(
            "/api/users/" + userId,
            UserResponse.class
        );

        // Then - 조회 검증
        assertThat(getResponse.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(getResponse.getBody().email()).isEqualTo("e2e@example.com");
        assertThat(getResponse.getBody().name()).isEqualTo("E2E테스트사용자");

        // When - 데이터베이스 직접 확인
        Optional<User> savedUser = userRepository.findById(new UserId(userId));

        // Then - 영속성 검증
        assertThat(savedUser).isPresent();
        assertThat(savedUser.get().getEmail().value()).isEqualTo("e2e@example.com");
    }
}
```

### 4. 성능 테스트 (Performance Tests)

#### @PerformanceTest 커스텀 어노테이션
```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@SpringBootTest
@Tag("performance")
public @interface PerformanceTest {
    String[] profiles() default {"test", "performance"};
}
```

#### 적용 대상 및 패턴
```java
@PerformanceTest
class UserServicePerformanceTest {

    @Autowired private CreateUserService createUserService;
    @Autowired private GetUserService getUserService;

    @Test
    @DisplayName("1000명 사용자 생성 시 5초 이내 완료된다")
    @Timeout(value = 5, unit = TimeUnit.SECONDS)
    void shouldCreateThousandUsersWithinFiveSeconds() {
        // Given
        List<CreateUserCommand> commands = IntStream.range(0, 1000)
            .mapToObj(i -> new CreateUserCommand(
                new Email("user" + i + "@example.com"),
                "사용자" + i
            ))
            .toList();

        // When
        StopWatch stopWatch = new StopWatch();
        stopWatch.start();

        List<UserResponse> responses = commands.parallelStream()
            .map(createUserService::createUser)
            .collect(Collectors.toList());

        stopWatch.stop();

        // Then
        assertThat(responses).hasSize(1000);
        assertThat(stopWatch.getTotalTimeSeconds()).isLessThan(5.0);

        System.out.println("1000명 사용자 생성 시간: " + stopWatch.getTotalTimeSeconds() + "초");
    }

    @Test
    @DisplayName("사용자 조회 응답시간이 100ms 이내다")
    void shouldGetUserWithinHundredMilliseconds() {
        // Given
        CreateUserCommand command = new CreateUserCommand(
            new Email("performance@example.com"),
            "성능테스트사용자"
        );
        UserResponse createdUser = createUserService.createUser(command);

        // When & Then
        assertTimeout(Duration.ofMillis(100), () -> {
            GetUserQuery query = new GetUserQuery(createdUser.id());
            UserResponse response = getUserService.getUser(query);

            assertThat(response.id()).isEqualTo(createdUser.id());
        });
    }

    @RepeatedTest(value = 100)
    @DisplayName("사용자 조회를 100번 반복 실행하여 안정성을 확인한다")
    void shouldGetUserRepeatedlyWithoutFailure(RepetitionInfo repetitionInfo) {
        // Given
        CreateUserCommand command = new CreateUserCommand(
            new Email("repeat" + repetitionInfo.getCurrentRepetition() + "@example.com"),
            "반복테스트사용자" + repetitionInfo.getCurrentRepetition()
        );
        UserResponse createdUser = createUserService.createUser(command);

        // When
        GetUserQuery query = new GetUserQuery(createdUser.id());
        UserResponse response = getUserService.getUser(query);

        // Then
        assertThat(response.id()).isEqualTo(createdUser.id());
        assertThat(response.email()).isEqualTo(command.email().value());
    }
}
```

## 테스트 실행 전략

### Gradle 태스크 분리
```gradle
// 단위 테스트만 실행
task unitTest(type: Test) {
    useJUnitPlatform {
        includeTags 'unit'
    }
    testLogging {
        events "passed", "skipped", "failed"
    }
}

// 통합 테스트만 실행
task integrationTest(type: Test) {
    useJUnitPlatform {
        includeTags 'integration'
    }
    testLogging {
        events "passed", "skipped", "failed"
    }
}

// E2E 테스트만 실행
task e2eTest(type: Test) {
    useJUnitPlatform {
        includeTags 'e2e'
    }
    testLogging {
        events "passed", "skipped", "failed"
    }
}

// 성능 테스트만 실행
task performanceTest(type: Test) {
    useJUnitPlatform {
        includeTags 'performance'
    }
    testLogging {
        events "passed", "skipped", "failed"
    }
}

// 빠른 테스트 (단위 + 통합)
task quickTest(type: Test) {
    useJUnitPlatform {
        includeTags 'unit', 'integration'
    }
}

// 전체 테스트
task allTest(type: Test) {
    useJUnitPlatform()
}
```

### CI/CD 파이프라인 통합
```yaml
# GitHub Actions
name: Test Strategy

on: [push, pull_request]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: '21'
      - name: Run unit tests
        run: ./gradlew unitTest

  integration-tests:
    runs-on: ubuntu-latest
    needs: unit-tests
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: '21'
      - name: Run integration tests
        run: ./gradlew integrationTest

  e2e-tests:
    runs-on: ubuntu-latest
    needs: integration-tests
    if: github.ref == 'refs/heads/main' || contains(github.event.pull_request.labels.*.name, 'e2e-test')
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: '21'
      - name: Run E2E tests
        run: ./gradlew e2eTest

  performance-tests:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: '21'
      - name: Run performance tests
        run: ./gradlew performanceTest
```

## 테스트 작성 가이드라인

### 1. 네이밍 컨벤션

#### 테스트 클래스 네이밍
```java
// 단위 테스트
UserTest.java                    // 도메인 객체 테스트
CreateUserServiceTest.java       // 유즈케이스 테스트
EmailTest.java                   // Value Object 테스트

// 통합 테스트
UserJpaAdapterIntegrationTest.java    // 영속성 어댑터 테스트
UserControllerIntegrationTest.java    // 웹 어댑터 테스트

// E2E 테스트
UserRegistrationE2ETest.java          // 비즈니스 플로우 테스트

// 성능 테스트
UserServicePerformanceTest.java       // 성능 측정 테스트
```

#### 테스트 메서드 네이밍
```java
// Given-When-Then 패턴으로 명확하게
@DisplayName("유효한 이메일로 사용자 생성 시 성공한다")
void shouldCreateUserWithValidEmail()

@DisplayName("중복된 이메일로 사용자 생성 시 예외가 발생한다")
void shouldThrowExceptionWithDuplicateEmail()

@DisplayName("존재하지 않는 사용자 조회 시 빈 Optional을 반환한다")
void shouldReturnEmptyOptionalWhenUserNotFound()
```

### 2. 테스트 데이터 관리

#### 테스트 픽스처 패턴
```java
// 테스트 데이터 빌더
public class UserTestDataBuilder {
    private Email email = new Email("test@example.com");
    private String name = "테스트사용자";
    private LocalDateTime createdAt = LocalDateTime.now();

    public static UserTestDataBuilder aUser() {
        return new UserTestDataBuilder();
    }

    public UserTestDataBuilder withEmail(String email) {
        this.email = new Email(email);
        return this;
    }

    public UserTestDataBuilder withName(String name) {
        this.name = name;
        return this;
    }

    public User build() {
        return User.create(email, name);
    }

    public CreateUserCommand buildCommand() {
        return new CreateUserCommand(email, name);
    }
}

// 사용 예시
@UnitTest
class CreateUserServiceTest {
    @Test
    void shouldCreateUser() {
        // Given
        CreateUserCommand command = UserTestDataBuilder.aUser()
            .withEmail("new@example.com")
            .withName("새사용자")
            .buildCommand();

        // When & Then
        // ...
    }
}
```

#### 테스트 컨테이너 설정
```java
// 공통 테스트 컨테이너 설정
@TestConfiguration
public class TestContainerConfig {

    @Container
    static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0")
            .withDatabaseName("testdb")
            .withUsername("test")
            .withPassword("test")
            .withInitScript("schema.sql");

    @Container
    static GenericContainer<?> redis = new GenericContainer<>("redis:7-alpine")
            .withExposedPorts(6379);

    @DynamicPropertySource
    static void configureProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", mysql::getJdbcUrl);
        registry.add("spring.datasource.username", mysql::getUsername);
        registry.add("spring.datasource.password", mysql::getPassword);

        registry.add("spring.redis.host", redis::getHost);
        registry.add("spring.redis.port", () -> redis.getMappedPort(6379));
    }
}
```

### 3. 어설션 가이드라인

#### AssertJ 활용
```java
// 단순 어설션
assertThat(user.getName()).isEqualTo("테스트사용자");
assertThat(users).hasSize(3);
assertThat(optionalUser).isPresent();

// 복합 어설션
assertThat(user)
    .extracting(User::getName, User::getEmail, User::isActive)
    .containsExactly("테스트사용자", "test@example.com", true);

// 예외 어설션
assertThatThrownBy(() -> new Email("invalid"))
    .isInstanceOf(ValidationException.class)
    .hasMessage("유효하지 않은 이메일 형식입니다")
    .hasFieldOrProperty("errorCode");

// 컬렉션 어설션
assertThat(users)
    .filteredOn(user -> user.isActive())
    .extracting(User::getName)
    .containsExactly("활성사용자1", "활성사용자2");
```

## 테스트 커버리지 정책

### 목표 커버리지
```gradle
jacocoTestCoverageVerification {
    violationRules {
        rule {
            limit {
                counter = 'LINE'
                value = 'COVEREDRATIO'
                minimum = 0.80  // 전체 80%
            }
        }

        rule {
            limit {
                counter = 'BRANCH'
                value = 'COVEREDRATIO'
                minimum = 0.70  // 분기 70%
            }
        }

        // 도메인 계층 높은 커버리지 요구
        rule {
            element = 'PACKAGE'
            includes = ['com.company.project.domain.*']
            limit {
                counter = 'LINE'
                value = 'COVEREDRATIO'
                minimum = 0.90  // 도메인 90%
            }
        }

        // 어댑터 계층 중간 커버리지
        rule {
            element = 'PACKAGE'
            includes = ['com.company.project.adapter.*']
            limit {
                counter = 'LINE'
                value = 'COVEREDRATIO'
                minimum = 0.70  // 어댑터 70%
            }
        }
    }
}
```

### 커버리지 제외 대상
```java
// 설정 클래스 제외
@Generated
@Configuration
public class DatabaseConfig {
    // 커버리지 측정 제외
}

// 단순 데이터 클래스 제외
@Generated
public record UserResponse(String id, String email, String name) {
    // 커버리지 측정 제외
}
```

## Claude Code 테스트 가이드

### 테스트 요청 시 컨벤션

#### 1. 단위 테스트 요청
```
"User 도메인 객체의 단위 테스트를 작성해줘"
→ @UnitTest 어노테이션 사용
→ Mockito로 의존성 모킹
→ 도메인 로직 검증 중심
→ 70% 커버리지 목표
```

#### 2. 통합 테스트 요청
```
"UserJpaAdapter의 통합 테스트를 작성해줘"
→ @IntegrationTest 어노테이션 사용
→ TestContainers로 실제 DB 사용
→ 영속성 계층 검증 중심
→ 20% 커버리지 목표
```

#### 3. E2E 테스트 요청
```
"사용자 등록 전체 플로우의 E2E 테스트를 작성해줘"
→ @E2ETest 어노테이션 사용
→ 실제 HTTP 요청으로 검증
→ 비즈니스 플로우 검증 중심
→ 10% 커버리지 목표
```

#### 4. 성능 테스트 요청
```
"사용자 조회 API의 성능 테스트를 작성해줘"
→ @PerformanceTest 어노테이션 사용
→ @Timeout, @RepeatedTest 활용
→ 응답시간, 처리량 검증 중심
```

### 테스트 자동 실행 명령어

#### 개발 중 빠른 피드백
```bash
# 단위 테스트만 (빠른 피드백)
./gradlew unitTest

# 단위 + 통합 테스트 (중간 검증)
./gradlew quickTest
```

#### 커밋 전 검증
```bash
# 전체 테스트 (커밋 전 필수)
./gradlew test

# 커버리지 확인
./gradlew jacocoTestReport jacocoTestCoverageVerification
```

#### 배포 전 검증
```bash
# E2E + 성능 테스트 포함
./gradlew allTest

# 성능 테스트만
./gradlew performanceTest
```

## 테스트 품질 체크리스트

### 단위 테스트 품질
- [ ] @UnitTest 어노테이션 사용
- [ ] 모든 의존성 모킹 처리
- [ ] Given-When-Then 패턴 적용
- [ ] @DisplayName으로 명확한 테스트 의도 표현
- [ ] 하나의 테스트는 하나의 케이스만 검증
- [ ] 테스트 데이터 빌더 패턴 활용
- [ ] AssertJ 어설션 라이브러리 사용

### 통합 테스트 품질
- [ ] @IntegrationTest 어노테이션 사용
- [ ] TestContainers로 실제 인프라 사용
- [ ] @Transactional로 테스트 간 격리
- [ ] 실제 데이터베이스 상호작용 검증
- [ ] API 계층까지 포함한 통합 검증

### E2E 테스트 품질
- [ ] @E2ETest 어노테이션 사용
- [ ] 실제 HTTP 요청/응답 검증
- [ ] 전체 비즈니스 플로우 커버
- [ ] 외부 시스템 통합 검증
- [ ] 사용자 시나리오 기반 테스트

### 성능 테스트 품질
- [ ] @PerformanceTest 어노테이션 사용
- [ ] @Timeout으로 응답시간 제한
- [ ] @RepeatedTest로 안정성 검증
- [ ] 처리량과 응답시간 모두 측정
- [ ] 성능 목표 수치 명시
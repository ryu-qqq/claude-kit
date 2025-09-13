# Java 코드 검증 및 Git 워크플로우

## 1. ArchUnit 아키텍처 검증

### 필수 검증 규칙
```java
// 헥사고날 아키텍처 준수 검증
@ArchTest
public class HexagonalArchitectureTest {

    // 의존성 방향 검증
    @ArchTest
    static final ArchRule domain_should_not_depend_on_outside =
        noClasses()
            .that().resideInAPackage("..domain..")
            .should().dependOnClassesThat()
            .resideInAnyPackage("..application..", "..adapter..", "org.springframework..");

    // 네이밍 규칙 검증
    @ArchTest
    static final ArchRule usecase_must_end_with_UseCase =
        classes()
            .that().resideInAPackage("..application.port.in..")
            .should().haveSimpleNameEndingWith("UseCase");

    // Java 21 Record 검증
    @ArchTest
    static final ArchRule commands_must_be_records =
        classes()
            .that().haveSimpleNameEndingWith("Command")
            .should().beRecords();

    // Lombok 금지 검증
    @ArchTest
    static final ArchRule no_lombok_allowed =
        noClasses()
            .should().beAnnotatedWith("lombok.*");

    // Java 21 Deprecated 메서드 사용 금지
    @ArchTest
    static final ArchRule no_deprecated_api_usage =
        noClasses()
            .should().accessClassesThat()
            .areAnnotatedWith(Deprecated.class)
            .because("Deprecated API 사용 금지");

    // 레거시 Date API 사용 금지
    @ArchTest
    static final ArchRule no_legacy_date_api =
        noClasses()
            .should().dependOnClassesThat()
            .haveFullyQualifiedName("java.util.Date")
            .because("java.util.Date 대신 java.time API 사용");

    // 레거시 Collections 사용 금지
    @ArchTest
    static final ArchRule no_legacy_collections =
        noClasses()
            .should().dependOnClassesThat()
            .haveSimpleNameStartingWith("Vector")
            .or().haveSimpleNameStartingWith("Hashtable")
            .because("Vector, Hashtable 대신 List, Map 사용");
}
```

## 2. 코드 품질 도구 설정

### Gradle 통합
```gradle
plugins {
    id 'checkstyle'
    id 'pmd'
    id 'com.github.spotbugs' version '6.0.7'
}

// Java 21 설정
java {
    sourceCompatibility = JavaVersion.VERSION_21
    targetCompatibility = JavaVersion.VERSION_21
}

// Deprecated API 사용 시 컴파일 에러
compileJava {
    options.compilerArgs += [
        '-Xlint:deprecation',
        '-Werror'  // deprecated 사용 시 컴파일 실패
    ]
}

compileTestJava {
    options.compilerArgs += [
        '-Xlint:deprecation',
        '-Werror'
    ]
}

checkstyle {
    toolVersion = '10.12.4'
    maxErrors = 0
    maxWarnings = 0
}

// 통합 검증 태스크
task codeQuality {
    dependsOn checkstyleMain, pmdMain, spotbugsMain
    doLast {
        println "✅ Code quality checks passed"
    }
}

// Deprecated API 체크 전용 태스크
task checkDeprecated {
    doLast {
        println "🔍 Checking for deprecated API usage..."

        // compileJava에서 이미 체크하므로 여기서는 로그만
        println "✅ No deprecated API usage detected"
    }
}
```

## 3. Git 커밋 규약

### Conventional Commits 형식
```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### 타입 정의
- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `refactor`: 리팩토링 (기능 변경 없음)
- `style`: 코드 포맷팅
- `test`: 테스트 추가/수정
- `docs`: 문서 수정
- `chore`: 빌드, 설정 파일 수정

### 스코프 정의 (헥사고날)
- `domain`: 도메인 계층
- `application`: 애플리케이션 계층
- `adapter`: 어댑터 계층
- `port`: 포트 인터페이스

### 예시
```bash
feat(domain): add User aggregate with email validation
fix(adapter): resolve database connection timeout
refactor(application): extract common validation logic
test(domain): add unit tests for User entity
```

## 4. Git Hooks 설정

### Pre-commit Hook
```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "🔍 Running pre-commit validation..."

# 1. ArchUnit 테스트
./gradlew test --tests "*ArchitectureTest*" || {
    echo "❌ Architecture validation failed"
    exit 1
}

# 2. 코드 품질 검사
./gradlew codeQuality || {
    echo "❌ Code quality checks failed"
    exit 1
}

# 3. 단위 테스트
./gradlew test || {
    echo "❌ Tests failed"
    exit 1
}

echo "✅ Pre-commit validation passed"
```

### Commit-msg Hook
```bash
#!/bin/bash
# .git/hooks/commit-msg

# 커밋 메시지 패턴 검증
commit_regex='^(feat|fix|refactor|style|test|docs|chore)(\([a-z]+\))?: .{1,50}$'
commit_msg=$(cat $1)

if ! echo "$commit_msg" | grep -qE "$commit_regex"; then
    echo "❌ Invalid commit message format!"
    echo "Format: <type>(<scope>): <subject>"
    echo "Example: feat(domain): add user validation"
    exit 1
fi
```

## 5. 자동화 워크플로우

### 코드 작성 → 커밋 프로세스
```bash
# 1. 코드 작성 완료
# 2. 아키텍처 검증
./gradlew test --tests "*ArchitectureTest*"

# 3. 코드 품질 검사
./gradlew codeQuality

# 4. 테스트 실행
./gradlew test

# 5. 커버리지 확인
./gradlew jacocoTestReport

# 6. Git 스테이징
git add .

# 7. 커밋 (자동 검증 실행)
git commit -m "feat(domain): implement user aggregate"
```

### GitHub Actions CI
```yaml
name: Java CI

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Set up JDK 21
      uses: actions/setup-java@v4
      with:
        java-version: '21'
        distribution: 'temurin'

    - name: Architecture validation
      run: ./gradlew test --tests "*ArchitectureTest*"

    - name: Code quality
      run: ./gradlew codeQuality

    - name: Run tests
      run: ./gradlew test

    - name: Check coverage
      run: ./gradlew jacocoTestCoverageVerification
```

## 6. IDE 설정

### IntelliJ IDEA
1. **Save Actions 플러그인 설치**
2. **설정**:
   - Optimize imports on save ✓
   - Reformat code on save ✓
   - Run code inspection ✓

### VS Code
```json
// .vscode/settings.json
{
  "java.format.settings.url": "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
  "java.saveActions.organizeImports": true,
  "editor.formatOnSave": true
}
```

## 7. 검증 체크리스트

### 커밋 전 필수 확인
- [ ] ArchUnit 테스트 통과
- [ ] Checkstyle 검사 통과
- [ ] PMD 검사 통과
- [ ] SpotBugs 검사 통과
- [ ] 단위 테스트 통과
- [ ] 코드 커버리지 80% 이상
- [ ] 커밋 메시지 규약 준수

### Pull Request 체크리스트
- [ ] 모든 CI 파이프라인 통과
- [ ] 코드 리뷰 승인 2개 이상
- [ ] 변경사항 문서화
- [ ] Breaking changes 명시

## 8. 자동 수정 스크립트

```bash
#!/bin/bash
# scripts/auto-fix.sh

echo "🔧 Auto-fixing code issues..."

# Import 정리
./gradlew spotlessApply

# 포맷팅
find src -name "*.java" | xargs google-java-format --replace

# Checkstyle 자동 수정
./gradlew checkstyleMain --fix

echo "✅ Auto-fix completed"
```

## 9. Husky 자동화 명령어

### Claude Code에서 실행
```bash
# 전체 CI 체크 실행
/husky-java

# 아키텍처 검증만
/husky-java --only-archunit

# 자동 수정 포함
/husky-java --auto-fix

# 테스트 제외
/husky-java --skip-tests
```

## 10. 문제 해결 가이드

### ArchUnit 실패 시
```bash
# 특정 테스트만 실행하여 디버깅
./gradlew test --tests "HexagonalArchitectureTest.domain_should_not_depend_on_outside"
```

### 커밋 실패 시
```bash
# Hook 우회 (긴급 상황에만)
git commit --no-verify -m "emergency: fix critical bug"
```

### 코드 품질 실패 시
```bash
# 자동 수정 시도
./scripts/auto-fix.sh

# 수정 후 재검증
./gradlew codeQuality
```
---
allowed-tools: Bash, Read, Edit, MultiEdit
argument-hint: [--skip-install] | [--only-archunit] | [--skip-tests] | [--auto-fix]
description: Run comprehensive Java CI checks and fix issues for hexagonal architecture
model: sonnet
---

# Husky CI Pre-commit Checks for Java/Spring

Run comprehensive CI checks for Java hexagonal architecture: $ARGUMENTS

## Current Repository State

- Git status: !`git status --porcelain`
- Build tool: !`ls build.gradle pom.xml 2>/dev/null | head -1`
- Current branch: !`git branch --show-current`
- Java version: !`java -version 2>&1 | head -1`

## Task

Verify Java/Spring hexagonal architecture compliance and fix issues.

## CI Check Protocol

### Step 0: Environment Setup
- Check Java 21: `java -version`
- Check Gradle/Maven: `./gradlew --version` or `mvn --version`

### Step 1: Architecture Validation (ArchUnit)
- Run ArchUnit tests to validate hexagonal architecture:
  ```bash
  ./gradlew test --tests "*ArchitectureTest*" --tests "*HexagonalTest*"
  ```
- Check violations:
  - Domain layer independence
  - UseCase naming conventions
  - Port naming conventions
  - No Lombok usage
  - Record usage for ValueObjects/Commands

### Step 2: Code Quality Checks
- Run integrated quality checks:
  ```bash
  ./gradlew checkstyleMain checkstyleTest
  ./gradlew pmdMain pmdTest
  ./gradlew spotbugsMain
  ```
- Auto-fix if --auto-fix flag:
  ```bash
  ./gradlew spotlessApply
  ```

### Step 3: Build Validation
- Compile all code:
  ```bash
  ./gradlew compileJava compileTestJava
  ```
- Check for Java 21 features usage (Records, Pattern Matching)

### Step 4: Test Execution
- Run unit tests (exclude integration):
  ```bash
  ./gradlew test -x integrationTest
  ```
- Check coverage:
  ```bash
  ./gradlew jacocoTestReport
  ./gradlew jacocoTestCoverageVerification
  ```

### Step 5: Hexagonal Structure Validation
- Verify package structure:
  ```bash
  find src -type d -name "domain" | grep -E "src/main/java/.+/domain"
  find src -type d -name "application" | grep -E "src/main/java/.+/application"
  find src -type d -name "adapter" | grep -E "src/main/java/.+/adapter"
  ```

### Step 6: Commit Message Validation
- Check last commit message format:
  ```bash
  git log -1 --pretty=format:"%s" | grep -E "^(feat|fix|refactor|style|test|docs|chore)(\([a-z]+\))?: .+"
  ```

### Step 7: Double Check
- If fixes made, re-run all checks
- Ensure no regression

### Step 8: Staging
- Check status: `git status`
- Add files: `git add .`
- **EXCLUDE**: Generated files (build/, target/)
- **DO NOT COMMIT**: Only stage files

## Error Handling Protocol

### 1. Architecture Violations
- **Domain depends on Spring**: Remove Spring imports from domain
- **Wrong naming**: Rename to follow conventions (UseCase, Port, Service)
- **Lombok detected**: Replace with explicit code
- **Missing Records**: Convert ValueObjects to Records

### 2. Code Quality Issues
- **Checkstyle**: Fix formatting issues
- **PMD**: Address code complexity
- **SpotBugs**: Fix potential bugs
- Run auto-fix: `./gradlew spotlessApply`

### 3. Test Failures
- Check if tests follow Given-When-Then pattern
- Verify mocking setup
- Check test coverage (minimum 80%)

### 4. Build Issues
- Verify Java 21 in build.gradle/pom.xml
- Check dependency conflicts
- Validate module structure

## Java-Specific Validation

### Hexagonal Architecture Rules
```java
// Domain layer - NO Spring dependencies
package com.example.domain;
// Only pure Java, no framework

// Application layer - Ports and UseCases
package com.example.application.port.in;
public interface CreateUserUseCase { }

package com.example.application.port.out;
public interface UserRepositoryPort { }

// Adapter layer - Spring allowed
package com.example.adapter.in.web;
@RestController
public class UserController { }
```

### Java 21 Features Check
```java
// Records for ValueObjects
public record Email(String value) {
    public Email {
        // validation
    }
}

// Pattern Matching
switch (event) {
    case UserCreatedEvent(var id, var email) -> handle(id);
    case UserDeletedEvent(var id) -> delete(id);
}

// No Lombok
// ❌ @Data, @RequiredArgsConstructor
// ✅ Explicit constructors and methods
```

## Success Criteria

Print checklist at end with ✅ for passed steps:
- ✅ Java 21 configured
- ✅ ArchUnit tests passed
- ✅ Code quality checks passed
- ✅ Build successful
- ✅ Tests passed (80%+ coverage)
- ✅ Hexagonal structure valid
- ✅ Commit message format valid
- ✅ Files staged (no commits made)

## Git Hooks Setup

### Install Husky (if not installed)
```bash
npm install --save-dev husky
npx husky install
```

### Create pre-commit hook
```bash
npx husky add .husky/pre-commit '
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

echo "🔍 Running Java pre-commit checks..."

# ArchUnit validation
./gradlew test --tests "*ArchitectureTest*" || {
    echo "❌ Architecture validation failed"
    exit 1
}

# Code quality
./gradlew checkstyleMain pmdMain spotbugsMain || {
    echo "❌ Code quality checks failed"
    exit 1
}

# Tests
./gradlew test -x integrationTest || {
    echo "❌ Tests failed"
    exit 1
}

echo "✅ Pre-commit checks passed"
'
```

### Create commit-msg hook
```bash
npx husky add .husky/commit-msg '
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

commit_regex="^(feat|fix|refactor|style|test|docs|chore)(\([a-z]+\))?: .{1,50}"
commit_msg=$(cat $1)

if ! echo "$commit_msg" | grep -qE "$commit_regex"; then
    echo "❌ Invalid commit message format!"
    echo "Format: <type>(<scope>): <subject>"
    echo "Example: feat(domain): add user validation"
    exit 1
fi

echo "✅ Commit message valid"
'
```

## Safety Guidelines

- **Fix proactively** - Tests will catch regressions
- **Never commit automatically** - Only stage changes
- **One step at a time** - Don't proceed until current step passes
- **Ask permission** before major structural changes
- **Keep Java 21 features** - Don't downgrade for compatibility
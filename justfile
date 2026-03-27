default:
    @just --list

# Format Java source files using Spotless
format:
    ./gradlew spotlessApply

# Check formatting and run Error Prone static analysis (via compilation)
lint:
    ./gradlew spotlessCheck classes testClasses

# Run tests
test:
    ./gradlew test

# Build the project
build:
    ./gradlew build

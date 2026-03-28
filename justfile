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

# Run the demo app with the profiler and open the HTML report
demo:
    ./gradlew :example:profileRun
    @echo "---"
    @echo "Report: $(ls -t example/build/profile-output/*.html | head -1)"
    @open "$(ls -t example/build/profile-output/*.html | head -1)" 2>/dev/null || true

#!/bin/bash

# Check if in correct directory with Xcode project
if [ ! -d "Breesix.xcodeproj" ]; then
    echo "Error: Breesix.xcodeproj not found! Please ensure you're in the correct directory."
    exit 1
fi

# Ensure xcshareddata directory exists
echo "Checking xcshareddata directory..."

if [ ! -d "Breesix.xcodeproj/project.xcworkspace/xcshareddata" ]; then
    echo "Creating xcshareddata directory..."
    mkdir -p Breesix.xcodeproj/project.xcworkspace/xcshareddata
fi

if [ ! -d "Breesix.xcodeproj/project.xcworkspace/xcshareddata/swiftpm" ]; then
    echo "Creating swiftpm directory..."
    mkdir -p Breesix.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
fi

# Create Package.resolved if not present
if [ ! -f "Breesix.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    echo "Creating Package.resolved file..."
    touch Breesix.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
fi

# Resolve package dependencies
echo "Resolving package dependencies..."
xcodebuild -resolvePackageDependencies -project Breesix.xcodeproj -scheme Breesix

# Check if Package.resolved was generated
if [ -f "Breesix.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    echo "Package.resolved generated successfully."
else
    echo "Failed to generate Package.resolved."
    exit 1
fi

# Check if Package.swift exists in the current directory or parent
if [ -f "Package.swift" ]; then
    echo "Installing OpenAI dependencies..."
    swift package resolve
else
    echo "Error: Could not find Package.swift. Please ensure the script is run in the correct directory."
    exit 1
fi

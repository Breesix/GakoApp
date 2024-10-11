#!/bin/bash
#
ls .

cd ..

echo "Generating Xcode project..."
xcodegen

if [ ! -d "Breesix.xcodeproj" ]; then
    echo "Error: Breesix.xcodeproj not found!"
    exit 1
fi

if [ ! -d "Breesix.xcodeproj/project.xcworkspace" ]; then
    echo "Error: project.xcworkspace not found!"
    exit 1
fi

echo "Checking xcshareddata directory..."

if [ ! -d "Breesix.xcodeproj/project.xcworkspace/xcshareddata" ]; then
    echo "Creating xcshareddata directory..."
    mkdir -p Breesix.xcodeproj/project.xcworkspace/xcshareddata
fi

if [ ! -d "Breesix.xcodeproj/project.xcworkspace/xcshareddata/swiftpm" ]; then
    echo "Creating swiftpm directory..."
    mkdir -p Breesix.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
fi

if [ ! -f "Breesix.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    echo "Creating Package.resolved file..."
    touch Breesix.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
fi

echo "Resolving package dependencies..."
xcodebuild -resolvePackageDependencies -project Breesix.xcodeproj -scheme Breesix

if [ -f "Breesix.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved" ]; then
    echo "Package.resolved generated successfully."
else
    echo "Failed to generate Package.resolved."
    exit 1
fi

echo "Installing OpenAI dependencies..."
swift package resolve

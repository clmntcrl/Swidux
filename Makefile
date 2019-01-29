xcodeproj:
	xcodegen && xed .

test-macos:
	set -o pipefail && \
	xcodebuild test \
		-scheme Swidux_macOS \
		-destination platform="macOS" \

test-ios:
	set -o pipefail && \
	xcodebuild test \
		-scheme Swidux_iOS \
		-destination platform="iOS Simulator,name=iPhone XR,OS=12.1" \

test-swift:
	swift test

test-tvos:
	set -o pipefail && \
	xcodebuild test \
		-scheme Swidux_tvOS \
		-destination platform="tvOS Simulator,name=Apple TV 4K,OS=12.1" \

test-all: test-macos test-ios

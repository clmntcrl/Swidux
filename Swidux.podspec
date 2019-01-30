Pod::Spec.new do |s|
  s.name         = "Swidux"
  s.version      = "1.0"
  s.summary      = "Swift unidirectional data flow inspired by redux."

  s.homepage     = "https://github.com/clmntcrl/swidux"

  s.license      =  { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Clément Cyril" => "cyril@clmntcrl.io" }
  s.social_media_url   = "http://twitter.com/clmntcrl"

  s.swift_version = "4.2"

  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "10.0"

  s.source = {
    :git => "https://github.com/clmntcrl/swidux.git",
    :tag => s.version
  }

  s.frameworks = "XCTest"

  s.source_files  = "Sources", "Sources/**/*.swift"
end

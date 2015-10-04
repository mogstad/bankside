Pod::Spec.new do |spec|
  spec.name = "Bankside"
  spec.version = "0.1.0"
  spec.license = "MIT"
  spec.summary = "Simple fixture generation tool for your tests"
  spec.homepage = "https://github.com/mogstad/Bankside"
  spec.authors = { "Bjarne Mogstad" => "me@mogstad.co" }
  spec.source = { 
    :git => "https://github.com/mogstad/bankside.git", 
    :tag => "v#{spec.version}"
  }
  spec.ios.deployment_target = "8.0"
  spec.osx.deployment_target = "10.10"
  spec.source_files = "sources/*.swift"
  spec.requires_arc = true
end

require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "rn-webim"
  s.version      = 1.0.1
  s.summary      = "React Native wrapper for WebIM library"  # Add this line
  s.description  = <<-DESC
                  rn-webim
                   DESC
  s.homepage     = "https://github.com/shockhs/react-native-webim"
  s.license      = "MIT"
  s.authors      = { "Vagan Mkrtchyan" => "esaxco.vm@gmail.com" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/shockhs/react-native-webim.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,m,swift}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency "WebimMobileSDK"
  # ...
  # s.dependency "..."
end



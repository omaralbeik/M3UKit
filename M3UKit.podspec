Pod::Spec.new do |s|
    s.name = 'M3UKit'
    s.version = '0.8.1'
    s.summary = 'Modern framework for parsing m3u files'
    s.description = <<-DESC
    A modern framework for parsing m3u files.
    DESC
    s.homepage = 'https://github.com/omaralbeik/M3UKit'
    s.license = { :type => 'MIT', :file => 'LICENSE' }
    s.authors = { 'Omar Albeik' => 'https://twitter.com/omaralbeik' }
    s.module_name  = 'M3UKit'
    s.source = { :git => 'https://github.com/omaralbeik/M3UKit.git', :tag => s.version }
    s.source_files = 'Sources/**/*.swift'
    s.swift_versions = ['5.5', '5.6', '5.7']
    s.ios.deployment_target = '11.0'
    s.osx.deployment_target = '10.13'
    s.tvos.deployment_target = '11.0'
end

Pod::Spec.new do |s|

  s.name             = 'ASImageLoader'
  s.version          = '0.1.0'
  s.summary          = 'ASImageLoader - automated image loader'

  s.description      = <<-DESC
ASImageLoader - helper for image loading with configurable cache.
Equipped with automated function optimized for collections (UITableView and UICollectionView).
DESC

  s.homepage     = "https://github.com/Anobisoft/ASImageLoader"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Stanislav Pletnev" => "anobisoft@gmail.com" }
  s.social_media_url   = "https://twitter.com/Anobisoft"

  s.platform     = :ios, "8.3"
  s.source       = { :git => "https://github.com/Anobisoft/ASImageLoader.git", :tag => "v#{s.version}" }
  s.source_files  = "ASImageLoader/Classes/**/*.{h,m}"
  s.resources = "ASImageLoader/Resources/*.plist"
  s.framework  = "Foundation"
  s.dependency 'AnobiKit', '~> 0.2.19'
  s.requires_arc = true

end

# frozen_string_literal: true

require "digest/md5"
require "net/http"
require "tempfile"

puts "== Creating elasticsearch indices ==\n"

Post.__elasticsearch__.create_index!

puts "== Seeding database with sample content ==\n"

# Uncomment to see detailed logs
# ActiveRecord::Base.logger = ActiveSupport::Logger.new($stdout)

admin = User.find_or_create_by!(name: "admin") do |user|
  user.created_at = 2.weeks.ago
  user.password = "e621test"
  user.email = "admin@e621"
  user.level = User::Levels::ADMIN
end

CurrentUser.user = admin
CurrentUser.ip_addr = "127.0.0.1"

resources = YAML.load_file Rails.root.join("db", "seeds.yml")
resources["images"].each do |image|
  puts image["url"]

  data  = Net::HTTP.get(URI(image["url"]))
  file  = Tempfile.new.binmode
  file.write data

  md5     = Digest::MD5.hexdigest(data)
  service = UploadService.new({
    file: file,
    tag_string: image["tags"],
    rating: "s",
    md5: md5,
    md5_confirmation: md5
  })

  service.start!
end

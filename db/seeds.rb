# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# 管理者アカウントの初期データを作成
Admin.find_or_create_by!(email: 'admin@example.com') do |admin|
  admin.password = 'hiro0104'
  admin.password_confirmation = 'hiro0104'
end
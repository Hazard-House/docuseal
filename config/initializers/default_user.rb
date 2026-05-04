# frozen_string_literal: true

# TEMPORARY — remove after first login
Rails.application.config.after_initialize do
  next unless ActiveRecord::Base.connection.table_exists?(:users)
  next if User.exists?

  account = Account.create!(
    name: 'Brown Haven Homes',
    timezone: 'Eastern Time (US & Canada)',
    locale: 'en'
  )

  account.users.create!(
    first_name: 'Matt',
    last_name: 'Gray',
    email: 'matt@hazard.house',
    password: 'admin123!',
    role: 'admin'
  )

  account.encrypted_configs.create!(
    key: EncryptedConfig::ESIGN_CERTS_KEY,
    value: GenerateCertificate.call.transform_values(&:to_pem)
  )

  Rails.logger.info('[Setup] Default admin user created: matt@hazard.house')
rescue StandardError => e
  Rails.logger.warn("[Setup] Skipped default user creation: #{e.message}")
end

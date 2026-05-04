# frozen_string_literal: true

# TEMPORARY — remove after first login
Rails.application.config.after_initialize do
  next unless ActiveRecord::Base.connection.table_exists?(:users)

  account = Account.first_or_create!(
    name: 'Brown Haven Homes',
    timezone: 'Eastern Time (US & Canada)',
    locale: 'en'
  )

  user = User.find_by(email: 'matt@hazard.house')
  if user
    user.update!(password: 'admin123!')
    Rails.logger.info('[Setup] Reset password for matt@hazard.house')
  else
    account.users.create!(
      first_name: 'Matt',
      last_name: 'Gray',
      email: 'matt@hazard.house',
      password: 'admin123!',
      role: 'admin'
    )
    Rails.logger.info('[Setup] Created admin user: matt@hazard.house')
  end

  unless EncryptedConfig.exists?(account: account, key: EncryptedConfig::APP_URL_KEY)
    account.encrypted_configs.create!(
      key: EncryptedConfig::APP_URL_KEY,
      value: 'https://haven-sign-production.up.railway.app'
    )
  end

  unless EncryptedConfig.exists?(account: account, key: EncryptedConfig::ESIGN_CERTS_KEY)
    account.encrypted_configs.create!(
      key: EncryptedConfig::ESIGN_CERTS_KEY,
      value: GenerateCertificate.call.transform_values(&:to_pem)
    )
  end

  Docuseal.refresh_default_url_options!
  Rails.logger.info('[Setup] Default user and config ensured')
rescue StandardError => e
  Rails.logger.error("[Setup] FAILED: #{e.class} — #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}")
end

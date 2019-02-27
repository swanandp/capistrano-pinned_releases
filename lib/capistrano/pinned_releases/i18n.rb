# frozen_string_literal: true

require "i18n"

en = {
  wont_delete_pinned_release: "The release '%{release}' is pinned; it won't be deleted from %{host}",
}

I18n.backend.store_translations(:en, capistrano: en)

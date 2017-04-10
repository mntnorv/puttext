require_relative 'rxgettext/runner'
require_relative 'rxgettext/parser'

require 'fast_gettext'

module RXGetText
  FastGettext.add_text_domain('rxgettext', {
    path: File.expand_path('../../locale', __FILE__),
    type: :po
  })

  FastGettext.text_domain       = 'rxgettext'
  FastGettext.available_locales = ['en_US']
  FastGettext.locale            = 'en_US'
end

boorugtk_sources = [
  'main.vala',
  'window.vala',
  'cache.vala',
  'api/query.vala',
  'api/post.vala'
]

boorugtk_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('libhandy-1', version: '>= 1.0'),
  dependency('libsoup-2.4', version: '>= 2.66.0'),
  dependency('gxml-0.20', version: '>= 0.20.0'),
  dependency('gstreamer-1.0', version: '>= 1.0')
]

gnome = import('gnome')

boorugtk_sources += gnome.compile_resources('boorugtk-resources',
  'boorugtk.gresource.xml',
  c_name: 'boorugtk'
)

executable('boorugtk', boorugtk_sources,
  vala_args: '--target-glib=2.50',  dependencies: boorugtk_deps,
  install: true,
)

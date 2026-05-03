const path = require('path')

module.exports = {
  content: [
    path.resolve(__dirname, 'app/javascript/template_builder/dynamic_area.vue'),
    path.resolve(__dirname, 'app/javascript/template_builder/dynamic_section.vue')
  ],
  theme: {
    extend: {
      colors: {
        'base-100': '#ffffff',
        'base-200': '#faf6ee',
        'base-300': '#f2f5f8',
        'base-content': '#092b49'
      }
    }
  }
}

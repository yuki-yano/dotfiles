return {
  settings = {
    yaml = {
      schemas = require('schemastore').json.schemas(),
      validate = { enable = true },
    },
  },
}

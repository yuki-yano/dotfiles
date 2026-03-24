return {
  filetypes = { 'typescriptreact' },
  settings = {
    tailwindCSS = {
      classAttributes = {
        'class',
        'className',
        'class:list',
        'classList',
        '*Class',
        '*ClassName',
      },
      lint = {
        cssConflict = 'warning',
        invalidApply = 'error',
        invalidConfigPath = 'error',
        invalidScreen = 'error',
        invalidTailwindDirective = 'error',
        invalidVariant = 'error',
        recommendedVariantOrder = 'warning',
      },
      validate = true,
    },
  },
}

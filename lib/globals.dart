library trotter.globals;

const isRelease = bool.fromEnvironment("dart.vm.product");
const ApiDomain = isRelease == true
    ? 'https://trotter-api.ajibade.me'
    : 'http://localhost:3002';

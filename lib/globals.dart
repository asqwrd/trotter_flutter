library trotter.globals;

const isRelease = bool.fromEnvironment("dart.vm.product");
const ApiDomain = isRelease == true
    ? 'https://trotter-api.herokuapp.com'
    : 'http://localhost:3002';

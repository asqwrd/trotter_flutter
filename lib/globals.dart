library trotter.globals;

const isRelease = bool.fromEnvironment("dart.vm.product");
const ApiDomain = isRelease == true
    ? 'http://trotter-api.ajibade.me'
    : 'http://localhost:3002';
const GOOGLE_API_KEY = 'AIzaSyBGMENZRkGzoOY0DiRgq3dBuJ1OcEFjlPA';

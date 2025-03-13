<template>
  <div id="app">
    <h1>JSON内容渲染器</h1>
    <JsonViewer />
  </div>
</template>

<script>
import JsonViewer from './components/JsonViewer.vue'

export default {
  name: 'App',
  components: {
    JsonViewer
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  margin: 0 auto;
  max-width: 1200px;
  padding: 20px;
}

h1 {
  text-align: center;
  margin-bottom: 30px;
}
</style>

<template>
  <div class="json-viewer">
    <!-- 文件上传部分 -->
    <div class="upload-container">
      <label for="file-upload" class="upload-label">
        <span>选择JSON文件</span>
        <input
          type="file"
          id="file-upload"
          ref="fileInput"
          @change="handleFileUpload"
          accept=".json"
        />
      </label>
      <button class="demo-button" @click="loadDemoFile">加载示例文件</button>
      <div class="file-info" v-if="fileName">
        当前文件: {{ fileName }}
      </div>
    </div>

    <!-- 内容渲染部分 -->
    <div class="content-container" v-if="jsonData.length > 0">
      <div class="entry" v-for="(item, index) in jsonData" :key="index">
        <div class="entry-header">
          <div class="entry-id">ID: {{ item.id || '未知' }}</div>
          <div class="entry-source">问题来源: {{ item.source || '未知' }}</div>
        </div>
        
        <div class="entry-question" v-if="item.question">
          用户提问: {{ item.question }}
        </div>
        
        <div class="entry-optimized" v-if="item.optimized_query">
          <strong>优化后查询:</strong> <span v-html="processThinkTags(item.optimized_query)"></span>
        </div>
        
        <div class="entry-answer-container" v-if="item.answer">
          <div class="answer-header">回答内容</div>
          <div class="entry-answer" v-html="renderMarkdown(item.answer)"></div>
        </div>
        
        <div class="entry-context" v-if="item.context && item.context !== '无相关上下文'">
          <strong>上下文:</strong>
          <div class="context-text">{{ item.context }}</div>
        </div>
        
        <div class="entry-footer">
          <span class="entry-lang" v-if="item.lang">
            语言: {{ item.lang }}
          </span>
          <span class="entry-model" v-if="item.query_model">
            查询模型: {{ item.query_model }}
          </span>
          <span class="entry-model" v-if="item.answer_model">
            回答模型: {{ item.answer_model }}
          </span>
        </div>
      </div>
    </div>
    
    <div class="no-content" v-else>
      请上传JSON文件或点击"加载示例文件"按钮查看内容
    </div>
  </div>
</template>

<script>
import { marked } from 'marked';
import 'highlight.js/styles/github.css';
import hljs from 'highlight.js';

export default {
  name: 'JsonViewer',
  data() {
    return {
      jsonData: [],
      fileName: '',
    };
  },
  mounted() {
    // 配置marked
    marked.setOptions({
      highlight: function (code, lang) {
        const language = hljs.getLanguage(lang) ? lang : 'plaintext';
        return hljs.highlight(code, { language }).value;
      },
      breaks: true,
      gfm: true
    });
  },
  methods: {
    handleFileUpload(event) {
      const file = event.target.files[0];
      if (!file) return;
      
      this.fileName = file.name;
      
      const reader = new FileReader();
      reader.onload = e => {
        try {
          this.jsonData = JSON.parse(e.target.result);
        } catch (error) {
          console.error('JSON解析错误:', error);
          alert('JSON文件格式不正确');
        }
      };
      reader.readAsText(file);
    },
    async loadDemoFile() {
      try {
        const response = await fetch('/1.json');
        if (!response.ok) {
          throw new Error('无法加载示例文件');
        }
        this.jsonData = await response.json();
        this.fileName = '1.json (示例)';
      } catch (error) {
        console.error('加载示例文件错误:', error);
        alert('加载示例文件失败: ' + error.message);
      }
    },
    processThinkTags(text) {
      if (!text) return '';
      return text.replace(/<think>([\s\S]*?)<\/think>/g, 
        '<div class="think-section">$1</div>');
    },
    renderMarkdown(text) {
      if (!text) return '';
      // 处理<think>标签内的内容
      const processedText = this.processThinkTags(text);
      return marked(processedText);
    }
  }
}
</script>

<style scoped>
.json-viewer {
  width: 100%;
}

.upload-container {
  margin-bottom: 30px;
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 15px;
}

.upload-label {
  display: inline-block;
  padding: 10px 20px;
  background-color: #4CAF50;
  color: white;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.upload-label:hover {
  background-color: #45a049;
}

input[type="file"] {
  display: none;
}

.demo-button {
  padding: 10px 20px;
  background-color: #2196F3;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.demo-button:hover {
  background-color: #0b7dda;
}

.file-info {
  font-style: italic;
  color: #666;
  margin-left: 10px;
}

.content-container {
  background-color: white;
  border-radius: 5px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  padding: 20px;
}

.entry {
  margin-bottom: 30px;
  padding-bottom: 30px;
  border-bottom: 1px solid #eee;
}

.entry:last-child {
  margin-bottom: 0;
  padding-bottom: 0;
  border-bottom: none;
}

.entry-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 15px;
}

.entry-id {
  font-weight: bold;
  background-color: #f0f0f0;
  padding: 2px 8px;
  border-radius: 3px;
}

.entry-source {
  color: #666;
  font-style: italic;
}

.entry-question {
  font-weight: bold;
  font-size: 1.2em;
  margin-bottom: 15px;
}

.entry-optimized {
  padding: 10px 15px;
  border-radius: 4px;
  margin-bottom: 15px;
  border-left: 3px solid #888888;
  font-size: 0.95em;
}

.entry-answer-container {
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  padding: 15px;
  margin-bottom: 20px;
  box-shadow: 0 2px 6px rgba(0,0,0,0.05);
}

.entry-answer-container {
  border: 1px solid #e0e0e0;
  border-radius: 6px;
  padding: 15px;
  margin-bottom: 20px;
  box-shadow: 0 2px 6px rgba(0,0,0,0.05);
}

.entry-context {
  background-color: #f9f9f9;
  padding: 15px;
  border-radius: 4px;
  margin-bottom: 15px;
  font-size: 0.9em;
  color: #555;
}

.context-text {
  margin-top: 8px;
  line-height: 1.5;
  white-space: pre-line; /* Preserves line breaks but wraps text */
}

.entry-footer {
  display: flex;
  justify-content: space-between;
  font-size: 0.8em;
  color: #999;
  margin-top: 10px;
}

.entry-lang {
  font-size: 0.8em;
  color: #999;
  text-align: right;
}

.entry-model {
  font-style: italic;
}

.no-content {
  text-align: center;
  padding: 50px;
  color: #999;
  background-color: #f9f9f9;
  border-radius: 5px;
}

/* 为pre和code添加样式 */
pre {
  background-color: #f6f8fa;
  padding: 15px;
  border-radius: 4px;
  overflow-x: auto;
}

:deep(.think-section) {
  background-color: transparent;
  padding: 15px;
  border-radius: 4px;
  margin: 15px 0;
  color: #999; /* Changed from #777 to a lighter #999 */
  border-left: 3px solid #ccc;
}
</style>

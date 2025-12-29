package com.learnchinese.backend.controller;

import com.learnchinese.backend.service.GeminiService;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/chat")
public class ChatbotController {

    private final GeminiService geminiService;

    public ChatbotController(GeminiService geminiService) {
        this.geminiService = geminiService;
    }

    @PostMapping("/ask")
    public Map<String, String> ask(@RequestBody Map<String, String> request) {
        String question = request.get("question");
        String prompt = "Bạn là trợ lý dạy tiếng Trung cho người Việt mới bắt đầu. " +
                        "Hãy trả lời câu hỏi sau một cách đơn giản, tránh thuật ngữ học thuật: " + question;
        
        String answer = geminiService.generateContent(prompt);
        return Map.of("answer", answer);
    }
}

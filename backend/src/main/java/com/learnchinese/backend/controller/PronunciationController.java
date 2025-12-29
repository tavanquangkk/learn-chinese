package com.learnchinese.backend.controller;

import com.learnchinese.backend.service.GeminiService;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/pronunciation")
public class PronunciationController {

    private final GeminiService geminiService;

    public PronunciationController(GeminiService geminiService) {
        this.geminiService = geminiService;
    }

    @GetMapping("/explain")
    public Map<String, String> explain(@RequestParam String pinyin, @RequestParam String tone) {
        String prompt = "Hãy giải thích cách phát âm âm Pinyin '" + pinyin + "' với thanh " + tone + " (Tone " + tone + ") cho người Việt mới học tiếng Trung. " +
                        "Dùng từ ngữ đơn giản, dễ hiểu, có ví dụ và so sánh với tiếng Việt nếu có thể. " +
                        "Trả lời ngắn gọn dưới 100 từ.";
        
        String explanation = geminiService.generateContent(prompt);
        return Map.of("explanation", explanation);
    }
}

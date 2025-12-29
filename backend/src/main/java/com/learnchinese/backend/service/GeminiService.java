package com.learnchinese.backend.service;

import com.learnchinese.backend.dto.GeminiRequest;
import com.learnchinese.backend.dto.GeminiResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;

@Service
public class GeminiService {

    private final RestClient restClient;

    @Value("${gemini.api.key}")
    private String apiKey;

    @Value("${gemini.api.url}")
    private String apiUrl;

    public GeminiService(RestClient.Builder restClientBuilder) {
        this.restClient = restClientBuilder.build();
    }

    public String generateContent(String prompt) {
        String url = apiUrl + "?key=" + apiKey;
        
        GeminiRequest request = GeminiRequest.fromText(prompt);

        try {
            GeminiResponse response = restClient.post()
                    .uri(url)
                    .body(request)
                    .retrieve()
                    .body(GeminiResponse.class);

            return response != null ? response.getText() : "Error: Empty response";
        } catch (Exception e) {
            e.printStackTrace();
            return "Error calling Gemini API: " + e.getMessage();
        }
    }
}

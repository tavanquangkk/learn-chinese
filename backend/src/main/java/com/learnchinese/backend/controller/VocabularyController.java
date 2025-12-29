package com.learnchinese.backend.controller;

import com.learnchinese.backend.model.Vocabulary;
import com.learnchinese.backend.repository.VocabularyRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/vocabulary")
public class VocabularyController {

    private final VocabularyRepository vocabularyRepository;

    public VocabularyController(VocabularyRepository vocabularyRepository) {
        this.vocabularyRepository = vocabularyRepository;
    }

    @GetMapping
    public List<Vocabulary> getVocabulary(@RequestParam(required = false) String level) {
        if (level != null && !level.isEmpty()) {
            return vocabularyRepository.findByLevel(level);
        }
        return vocabularyRepository.findAll();
    }
    
    @PatchMapping("/{id}/remember")
    public ResponseEntity<Vocabulary> toggleRemember(@PathVariable String id) {
        Optional<Vocabulary> vocabOpt = vocabularyRepository.findById(id);
        if (vocabOpt.isPresent()) {
            Vocabulary vocab = vocabOpt.get();
            vocab.setRemembered(!vocab.isRemembered());
            return ResponseEntity.ok(vocabularyRepository.save(vocab));
        }
        return ResponseEntity.notFound().build();
    }
}
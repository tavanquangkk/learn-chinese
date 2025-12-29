package com.learnchinese.backend.repository;

import com.learnchinese.backend.model.Vocabulary;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface VocabularyRepository extends JpaRepository<Vocabulary, String> {
    List<Vocabulary> findByLevel(String level);
}

package com.learnchinese.backend.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
public class Vocabulary {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    
    private String simplified;
    private String traditional;
    private String pinyinWithNumbers;
    private String pinyin;
    
    @Column(length = 1000) // Tăng độ dài để chứa giải nghĩa chi tiết
    private String meaning;
    
    private String level;
    private boolean remembered;
}
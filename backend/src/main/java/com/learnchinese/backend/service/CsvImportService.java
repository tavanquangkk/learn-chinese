package com.learnchinese.backend.service;

import com.learnchinese.backend.model.Vocabulary;
import com.learnchinese.backend.repository.VocabularyRepository;
import com.opencsv.CSVReader;
import com.opencsv.CSVReaderBuilder;
import com.opencsv.RFC4180Parser;
import com.opencsv.RFC4180ParserBuilder;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

@Service
public class CsvImportService {

    private final VocabularyRepository repository;

    public CsvImportService(VocabularyRepository repository) {
        this.repository = repository;
    }

    @Transactional
    public void importCsv(String fileName, String level) {
        try {
            ClassPathResource resource = new ClassPathResource(fileName);
            if (!resource.exists()) {
                System.out.println("⚠️ File not found: " + fileName);
                return;
            }
            
            Reader reader = new InputStreamReader(resource.getInputStream(), StandardCharsets.UTF_8);
            
            // Sử dụng RFC4180Parser để xử lý chuẩn CSV có quote (") tốt hơn
            RFC4180Parser parser = new RFC4180ParserBuilder().build();
            CSVReader csvReader = new CSVReaderBuilder(reader)
                    .withCSVParser(parser)
                    .withSkipLines(1) // Skip Header
                    .build();
            
            List<String[]> rows = csvReader.readAll();
            List<Vocabulary> vocabList = new ArrayList<>();
            
            for (int i = 0; i < rows.size(); i++) {
                String[] row = rows.get(i);
                try {
                    if (row.length >= 5) {
                        Vocabulary v = new Vocabulary();
                        v.setSimplified(row[0].trim());
                        v.setTraditional(row[1].trim());
                        v.setPinyinWithNumbers(row[2].trim());
                        v.setPinyin(row[3].trim());
                        v.setMeaning(row[4].trim()); // Opencsv tự động bỏ dấu " bao quanh
                        v.setLevel(level);
                        v.setRemembered(false);
                        vocabList.add(v);
                    } else {
                        System.err.println("❌ Skipped line " + (i + 2) + " in " + fileName + ": Not enough columns (" + row.length + ")");
                    }
                } catch (Exception e) {
                    System.err.println("❌ Error processing line " + (i + 2) + " in " + fileName + ": " + e.getMessage());
                }
            }
            
            if (!vocabList.isEmpty()) {
                repository.saveAll(vocabList);
                System.out.println("✅ Imported " + vocabList.size() + " items from " + fileName + " (" + level + ")");
            }
            
        } catch (Exception e) {
            System.err.println("❌ Critical error importing " + fileName + ": " + e.getMessage());
            e.printStackTrace();
        }
    }
}
package com.learnchinese.backend;

import com.learnchinese.backend.repository.VocabularyRepository;
import com.learnchinese.backend.service.CsvImportService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    private final VocabularyRepository repository;
    private final CsvImportService csvImportService;

    public DataInitializer(VocabularyRepository repository, CsvImportService csvImportService) {
        this.repository = repository;
        this.csvImportService = csvImportService;
    }

    @Override
    public void run(String... args) {
        long count = repository.count();
        if (count == 0) {
            System.out.println("🚀 Database empty. Starting import from CSV...");
            csvImportService.importCsv("hsk1.csv", "HSK1");
            csvImportService.importCsv("hsk2.csv", "HSK2");
            csvImportService.importCsv("hsk3.csv", "HSK3");
        } else {
            System.out.println("ℹ️ Database already contains " + count + " items. Skipping import.");
            System.out.println("💡 To re-import, stop the server and delete the 'backend/data' folder.");
        }
    }
}
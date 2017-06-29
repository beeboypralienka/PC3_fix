tic

% -------------------------------------
% Tear-down semua display dan variable
% -------------------------------------
clc; clear;

% -----------------------------
% Load file CSV dataset mentah
% -----------------------------
PC3_01_Dataset = csvread('01_Data\PC3.csv');

% ----------------------------------------
% Load file CSV dataset (remove duplicate)
% ----------------------------------------
PC3_02_Unique = csvread('01_Data\PC3Unique.csv');

%==================================================================================================================================================================================
%                                              ********************** EBD FASE 1 **********************
%==================================================================================================================================================================================

% ----------------------------
% Hitung jumlah TRUE dan FALSE
% ----------------------------
jmlTrue = 0;
jmlFalse = 0;
for iJumlahTF = 1 : length(PC3_02_Unique)
    % -------------------
    % Hitung jumlah FALSE
    % -------------------
    if PC3_02_Unique(iJumlahTF,38) == 0
        jmlTrue = jmlTrue + 1;
    % -------------------
    % Hitung jumlah TRUE
    % -------------------
    else
        jmlFalse = jmlFalse + 1;
    end    
end

% ------------------------------------------------------------------------------
% Menghitung entropy parent di tahap EBD (menggunakan fungsi "entropyParentEBD")
% ------------------------------------------------------------------------------
jmlData = length(PC3_02_Unique);
entropyParent = entropyParentEBD_fix(jmlTrue,jmlFalse,jmlData);

% ------------------------------
% Rangkuman "PC3_03_Keterangan"
% ------------------------------
% [1] Jumlah Data
% [2] TRUE
% [3] FALSE
% [4] Entropy Parent
% --------------------------------------------------------
PC3_03_Keterangan = [jmlData jmlTrue jmlFalse entropyParent];

% ----------------------------------------------
% Data dipecah per fitur, kemudian diurutkan ASC
% ----------------------------------------------
for iFiturPecah = 1 : 37
    for iDataPecah = 1 : jmlData    
        PC3_04_DataFitur{1,iFiturPecah}(iDataPecah,:) = [PC3_02_Unique(iDataPecah,iFiturPecah) PC3_02_Unique(iDataPecah,38)];
        PC3_05_DataFiturASC{1,iFiturPecah} = sortrows(PC3_04_DataFitur{1,iFiturPecah});
    end    
end

% -------------------------------
% Data "PC3_05_DataFiturASC" di-split
% -------------------------------
for iFiturSplit = 1 : 37    
    for iDataSplit = 1 : jmlData - 1
        dataPertama = PC3_05_DataFiturASC{1,iFiturSplit}(iDataSplit,1); % Urutan iDataSplit
        dataKedua = PC3_05_DataFiturASC{1,iFiturSplit}(iDataSplit+1,1); % Urutan iDataSplit + 1
        PC3_06_DataFiturASC_Split{1,iFiturSplit}(iDataSplit,1) = (dataPertama+dataKedua)/2; % Ditambah dan dibagi dua, nilainya disimpan di kolom 1                   
    end
end

% --------------------------------------
% Kolom "PC3_06_DataFiturASC_Split" be like:
% --------------------------------------
% [1] Data Split
% [2] TRUE(<=)
% [3] FALSE(<=)
% [4] entropyChildren(<=)
% [5] TRUE(>)
% [6] FALSE(>)
% [7] entropyChildren(>)
% [8] INFO
% [9] GAIN
% --------------------------------------

% -------------------------------------------
% Proses update kolom "PC3_06_DataFiturASC_Split"
% -------------------------------------------
for iKolomUpdate = 1 : 37
%--
    for iBarisSplit = 1 : jmlData - 1        
        jmlTrueKurang = 0;
        jmlFalseKurang = 0;
        jmlTrueLebih = 0;
        jmlFalseLebih = 0;        
        for iBarisASC = 1 : jmlData            
            % -----------------------------------------------------------
            % Hitung jumlah TRUE dan FALSE dari kategoti ( <= ) dan ( > )
            % -----------------------------------------------------------
            dataSplit = PC3_06_DataFiturASC_Split{1,iKolomUpdate}(iBarisSplit,1);
            dataASC = PC3_05_DataFiturASC{1,iKolomUpdate}(iBarisASC,1);
            kelasASC = PC3_05_DataFiturASC{1,iKolomUpdate}(iBarisASC,2);
            % -------------
            % Kategori <=
            % -------------
            if dataASC <= dataSplit
                if kelasASC == 1                    
                    jmlTrueKurang = jmlTrueKurang + 1;
                else jmlFalseKurang = jmlFalseKurang + 1;
                end
            % ------------
            % Kategori >
            % ------------
            else
                if kelasASC == 1
                    jmlTrueLebih = jmlTrueLebih + 1;
                else jmlFalseLebih = jmlFalseLebih + 1;
                end
            end                                                            
        end        
        
        % -------------------------------------------------------
        % Update kolom "PC3_06_DataFiturASC_Split" [2], [3], [5], [6]
        % -------------------------------------------------------
        PC3_06_DataFiturASC_Split{1,iKolomUpdate}(iBarisSplit,2) = jmlTrueKurang;
        PC3_06_DataFiturASC_Split{1,iKolomUpdate}(iBarisSplit,3) = jmlFalseKurang;
        PC3_06_DataFiturASC_Split{1,iKolomUpdate}(iBarisSplit,5) = jmlTrueLebih;
        PC3_06_DataFiturASC_Split{1,iKolomUpdate}(iBarisSplit,6) = jmlFalseLebih;    
        
        % ------------------------------------------
        % Hitung ENTROPY CHILD dari parameter ( <= )
        % ------------------------------------------
        totalKurang = jmlTrueKurang + jmlFalseKurang; % Total jumlah TRUE dan jumlah FALSE dari parameter ( <= )
        % ----------------------------------------------------------------
        % Selama total jumlah TRUE dan FALSE di parameter ( <= ) bukan NOL
        % ----------------------------------------------------------------
        if totalKurang ~=0 
            piTrueKurang(iBarisSplit,1) = jmlTrueKurang / (jmlTrueKurang+jmlFalseKurang); % Hitung Pi TRUE ( <= )
            piFalseKurang(iBarisSplit,1) = jmlFalseKurang / (jmlTrueKurang+jmlFalseKurang); % Hitung Pi FALSE ( <= )
            % --------------------------------------------------------------------------------
            % Jika hasil Pi TRUE atau Pi FALSE itu NOL, dipastikan ENTROPY CHILD (<=) juga NOL            
            % --------------------------------------------------------------------------------
            if piTrueKurang(iBarisSplit,1) == 0 || piFalseKurang(iBarisSplit,1) == 0                 
                entropyChildKurang(iBarisSplit,1) = 0; % Entropy child ( <= ) dijadikan NOL
            % ---------------------------------------------------------------------
            % Jika Pi TRUE dan Pi FALSE bukan NOL, maka hitung ENTROPY CHILD ( <= )
            % ---------------------------------------------------------------------
            else entropyChildKurang = entropyChildrenEBD_fix(piTrueKurang, piFalseKurang,iBarisSplit);
            end                
        % ---------------------------------------------------------------------------------------------------------        
        % Jika total jumlah TRUE dan FALSE di parameter ( <= ) adalah NOL, dipastikan ENTROPY CHILD ( <= ) juga NOL
        % ---------------------------------------------------------------------------------------------------------
        else entropyChildKurang(iBarisSplit,1) = 0; % Entropy child ( <= ) dijadikan NOL
        end                           
                        
        % ------------------------------------------
        % Hitung ENTROPY CHILD dari parameter ( > )
        % ------------------------------------------
        totalLebih = jmlTrueLebih + jmlFalseLebih; % Total jumlah TRUE dan jumlah FALSE dari parameter ( > )
        % ----------------------------------------------------------------
        % Selama total jumlah TRUE dan FALSE di parameter ( > ) bukan NOL
        % ----------------------------------------------------------------
        if totalLebih ~= 0
            piTrueLebih(iBarisSplit,1) = jmlTrueLebih /  (jmlTrueLebih+jmlFalseLebih); % Hitung Pi TRUE ( > )
            piFalseLebih(iBarisSplit,1) = jmlFalseLebih / (jmlTrueLebih+jmlFalseLebih); % Hitung Pi FALSE ( > )                
            % --------------------------------------------------------------------------------
            % Jika hasil Pi TRUE atau Pi FALSE itu NOL, dipastikan entropyChild ( > ) juga NOL
            % --------------------------------------------------------------------------------
            if piTrueLebih(iBarisSplit,1) == 0 || piFalseLebih(iBarisSplit,1) == 0
                   entropyChildLebih(iBarisSplit,1) = 0; % Entropy child ( > ) dijadikan NOL            
            % ---------------------------------------------------------------------
            % Jika Pi TRUE dan Pi FALSE bukan NOL, maka hitung ENTROPY CHILD ( > )
            % ---------------------------------------------------------------------
            else entropyChildLebih = entropyChildrenEBD_fix(piTrueLebih, piFalseLebih,iBarisSplit);                   
            end
        % ----------------------------------------------------------------
        % Jika total jumlah TRUE dan FALSE adalah NOL pada parameter ( > )                
        % ----------------------------------------------------------------
        else entropyChildLebih(iBarisSplit,1) = 0; % Entropy child ( > ) dijadikan NOL
        end            
                                                            
        % ------------------------------------------------
        % Update kolom "PC3_06_DataFiturASC_Split" [4] dan [7]
        % ------------------------------------------------
        PC3_06_DataFiturASC_Split{1,iKolomUpdate}(iBarisSplit,4) = entropyChildKurang(iBarisSplit,1); % Ent. Child <=
        PC3_06_DataFiturASC_Split{1,iKolomUpdate}(iBarisSplit,7) = entropyChildLebih(iBarisSplit,1); % Ent. Child >                      
        
        % -----------------------------------------
        % Mencari nilai INFO dari setiap data split
        % -----------------------------------------
        dataChildKurang = (totalKurang/jmlData) * PC3_06_DataFiturASC_Split{1, iKolomUpdate}(iBarisSplit,4);
        dataChildLebih = (totalLebih/jmlData) * PC3_06_DataFiturASC_Split{1, iKolomUpdate}(iBarisSplit,7);
        INFOsplit(iBarisSplit,1) = (dataChildKurang + dataChildLebih);        
            
        % ------------------------------------
        % Mencari nilai GAIN dari setiap INFO
        % ------------------------------------
        GAINinfo(iBarisSplit,1) = PC3_03_Keterangan(1,4) - INFOsplit(iBarisSplit,1);                
        
        % ------------------------------------------------
        % Update kolom "PC3_06_DataFiturASC_Split" [8] dan [9]
        % ------------------------------------------------
        PC3_06_DataFiturASC_Split{1,iKolomUpdate}(iBarisSplit,8) = INFOsplit(iBarisSplit,1); % nilai INFO dari data SPLIT
        PC3_06_DataFiturASC_Split{1,iKolomUpdate}(iBarisSplit,9) = GAINinfo(iBarisSplit,1); % nilai INFO dari data SPLIT
    end
    
    % ---------------------------------
    % Distinct "PC3_06_DataFiturASC_Split"
    % ---------------------------------    
    PC3_07_DataFiturASC_Split_Distinct{1,iKolomUpdate} = unique(PC3_06_DataFiturASC_Split{1,iKolomUpdate},'rows');    
        
    % -------------------------------------------------------------------------------------------
    % Mencari nilai BEST SPLIT berdasarkan nilai GAIN tertinggi (max) di "Mtraining02UrutSplit_1"
    % -------------------------------------------------------------------------------------------
    [Nilai,BarisKe] = max(PC3_07_DataFiturASC_Split_Distinct{1,iKolomUpdate}(:,9)); % Ambil urutan ke berapa si split terbaik itu dan ambil nilai max gain-nya
    angkaBestSplit = PC3_07_DataFiturASC_Split_Distinct{1, iKolomUpdate}(BarisKe,1); % Angka split terbaik
    PC3_08_BEST_Split_1{1,iKolomUpdate} = [BarisKe angkaBestSplit Nilai]; % nilai max Gain dari data split ke berapa    
    
    % ----------------------------------------
    % Keterangan kolom "PC3_08_BEST_Split_1":
    % ----------------------------------------
    % [1] Baris ke berapa
    % [2] Angka BEST SPLIT
    % [3] Nilai Max GAIN
    % ----------------------------------------
%--
end

% --------------------------------------------------------------------------------
% Diskritisasi data "PC3_04_DataFitur" menjadi BINER berdasakan best split ( <= , > )
% --------------------------------------------------------------------------------
for iKolomDiskrit = 1 : 37 % Iterasi fitur exclude kelas    
    for iBarisDiskrit = 1 : jmlData
        dataAwal = PC3_04_DataFitur{1, iKolomDiskrit}(iBarisDiskrit,1);
        bestSplit = PC3_08_BEST_Split_1{1,iKolomDiskrit}(1,2) ;
        % ------------------------------
        % Kalau data AWAL <= BEST SPLIT
        % ------------------------------
        if dataAwal <= bestSplit
            PC3_09_Biner_1(iBarisDiskrit,iKolomDiskrit) = 0;            
        % -----------------------------
        % Kalau data AWAL > BEST SPLIT
        % -----------------------------
        else PC3_09_Biner_1(iBarisDiskrit,iKolomDiskrit) = 1;
        end
        
        % --------------------------------------------
        % Menambahkan kolom kelas ke "PC3_09_Biner_1"
        % --------------------------------------------
        if iKolomDiskrit == 37 %Fitur ke 37                          
            dataKelasnya = PC3_04_DataFitur{1,iKolomDiskrit}(iBarisDiskrit,2); % ambil data kelas dari "PC3_04_DataFitur"
            PC3_09_Biner_1(iBarisDiskrit,iKolomDiskrit+1) = dataKelasnya; % data kelas disimpan di kolom ke 38
        end                                    
    end           
end   
        
% ----------------------------------------------------------------------
% Distinct data MtrainingBiner_1 --> agar tidak ada redudansi data biner
% ----------------------------------------------------------------------
PC3_10_Biner_1_Unique = unique(PC3_09_Biner_1,'rows'); % Data redundan diseleksi (include kelas)

% ------------------------------------------------------------------------------------------------------------------------------
% Jika jumlah "Mtraining05UniqueBiner_1" DENGAN dan TANPA kelas itu berbeda, pasti ada duplikasi data dengan kelas yang berbeda
% ------------------------------------------------------------------------------------------------------------------------------
uniqueDenganKelas = length(PC3_10_Biner_1_Unique); % jumlah unique dengan kelasnya juga
uniqueTanpaKelas = length(unique(PC3_10_Biner_1_Unique(:,1:37),'rows')); % Data unique tanpa kelas
if  uniqueTanpaKelas ~= uniqueDenganKelas % Data unique tanpa kelas ~= data unique 
%---

    % ----------------------------------------------------------------------------
    % Perbandingan jumlah unique DENGAN dan TANPA kelas di "PC3_10_Biner_1_Unique"
    % ----------------------------------------------------------------------------
    PC3_11_Perbandingan_1 = [uniqueTanpaKelas uniqueDenganKelas uniqueDenganKelas-uniqueTanpaKelas]; 
        
%==================================================================================================================================================================================
%                                              ********************** EBD FASE 2 **********************
%==================================================================================================================================================================================
    
    % ----------------------------------------------------------------------------------------------------
    % Pembagian data "PC3_07_DataFiturASC_Split_Distinct" berdasarkan "PC3_08_BEST_Split_1" menjadi 2A dan 2B
    % ----------------------------------------------------------------------------------------------------
    for ikolomFoldSplit = 1 : 37        
        A = 1; % Karena counter A dan B berbeda
        B = 1; % Karena counter A dan B berbeda
        jmlSplitDist = size(PC3_07_DataFiturASC_Split_Distinct{1,ikolomFoldSplit},1); % Pake size, bukan length, 3 row x 9 col maka length muncul 9                     
        for iBarisData = 1 : jmlSplitDist            
            bestSplit_1 = PC3_08_BEST_Split_1{1,ikolomFoldSplit}(1,2);
            dataSplit_1 = PC3_07_DataFiturASC_Split_Distinct{1,ikolomFoldSplit}(iBarisData,1);            
            if dataSplit_1 <= bestSplit_1 
                PC3_12_Split_1_2A{1,ikolomFoldSplit}(A,1) = dataSplit_1;
                A = A + 1;
            else
                PC3_13_Split_1_2B{1,ikolomFoldSplit}(B,1) = dataSplit_1;                
                B = B + 1;
            end
        end
    end        
        
    % -------------------------------
    % Split data "PC3_12_FiturASC_2A"
    % -------------------------------
    for iKolomFold2A = 1 : 37                               
        jumlah2A = size(PC3_12_Split_1_2A{1,iKolomFold2A},1); % Banyaknya data di "PC3_12_FiturASC_2A"            
        nilaiBestSplit = PC3_08_BEST_Split_1{1,iKolomFold2A}(1,2); % Nilai best splitnya berapa
        % ---------------------------------------------
        % Jumlah "PC3_12_Split_1_2A" 1, ga perlu split
        % ---------------------------------------------
        if jumlah2A == 1                
            PC3_14_Split_1_2A_Split{1,iKolomFold2A}(1,1) = nilaiBestSplit;                
        % -----------------------------------------
        % Kalau lebih dari satu datanya, siap split
        % -----------------------------------------
        else            
            for iBaris2A = 1 : jumlah2A - 1 % Dikurangi satu                                                                                                                
                % ----------------------------------------
                % Urutan data yang terakhir tidak di-split
                % ----------------------------------------
                dataPertama = PC3_12_Split_1_2A{1,iKolomFold2A}(iBaris2A,1); % Urutan data split pertama
                dataKedua = PC3_12_Split_1_2A{1,iKolomFold2A}(iBaris2A+1,1); % Urutan data split kedua
                hasilSplit2A = (dataPertama+dataKedua)/2; % Ditambah dan dibagi dua, nilainya disimpan di kolom 1                                             
                PC3_14_Split_1_2A_Split{1,iKolomFold2A}(iBaris2A,1) = hasilSplit2A;                                        
            end
        end                            
    end
        
    % -------------------------------
    % Split data "Mtraining06Urut_2B"
    % -------------------------------        
    for iKolomFold2B = 1 : 37         
        % -------------------------------------------
        % Antisipasi, kalau "PC3_13_FiturASC_2B" = []
        % -------------------------------------------
        if size(PC3_13_Split_1_2B{1,iKolomFold2B},1) ~= 0                   
        %--                   
            jumlah2B = size(PC3_13_Split_1_2B{1,iKolomFold2B},1); % Banyaknya data di "PC3_13_FiturASC_2B"            
            nilai2B = PC3_13_Split_1_2B{1,iKolomFold2B}(1,1); % Nilai 2B satu-satunya            
            % --------------------------------------------------------
            % Jumlah data "PC3_13_FiturASC_2B" cuma 1, ga perlu split
            % --------------------------------------------------------
            if jumlah2B == 1                   
                PC3_15_Split_1_2B_Split{1,iKolomFold2B}(1,1) = nilai2B;                
            % -----------------------------------------
            % Kalau lebih dari satu datanya, siap split
            % -----------------------------------------
            else                
                for iBaris2B = 1 : jumlah2B - 1 % Dikurangi satu                                                                                                                    
                    % ----------------------------------------
                    % Urutan data yang terakhir tidak di-split
                    % ----------------------------------------
                    dataPertama = PC3_13_Split_1_2B{1,iKolomFold2B}(iBaris2B,1); % Urutan data split pertama
                    dataKedua = PC3_13_Split_1_2B{1,iKolomFold2B}(iBaris2B+1,1); % Urutan data split kedua
                    hasilSplit2B = (dataPertama+dataKedua)/2; % Ditambah dan dibagi dua, nilainya disimpan di kolom 1                                             
                    PC3_15_Split_1_2B_Split{1,iKolomFold2B}(iBaris2B,1) = hasilSplit2B;                                        
                end
            end                
        %--    
        end                                        
    end     
        
    % ---------------------------------------------------------------------------------------------------------------------------
    % Pembagian data "PC3_04_DataFitur" berdasarkan "PC3_08_BEST_Split_1" -> Jadi "PC3_16_DataFitur_2A" dan "PC3_17_DataFitur_2B"
    % ---------------------------------------------------------------------------------------------------------------------------
    for iKolomTraining = 1 : 37        
        A = 1;
        B = 1;
        for iBarisTraining = 1 : jmlData
            numerikAwal = PC3_04_DataFitur{1,iKolomTraining}(iBarisTraining,1);
            dataBestSplit = PC3_08_BEST_Split_1{1,iKolomTraining}(1,2);
            dataKelasnya = PC3_04_DataFitur{1,iKolomTraining}(iBarisTraining,2);
            % ------------------------------------
            % Kalau <= best split maka training 2A
            % ------------------------------------
            if numerikAwal <= dataBestSplit                
                PC3_16_DataFitur_2A{1,iKolomTraining}(A,:) = [numerikAwal dataKelasnya];
                A = A + 1;
            % ------------------------------------
            % Kalau > best split maka training 2B
            % ------------------------------------
            else                
                PC3_17_DataFitur_2B{1,iKolomTraining}(B,:) = [numerikAwal dataKelasnya];
                B = B + 1;
            end
        end
    end
    
    % -------------------------------------------------------------------
%1  % Update kolom pada "PC3_14_Split_1_2A_Split" dengan data training 2A
    % -------------------------------------------------------------------
    % Jumlah TRUE ( <= ) data split FASE 2A          [2] 
    % Jumlah FALSE ( <= ) data split FASE 2A         [3] 
    % Entropy CHILDREN ( <= ) di data split FASE 2A  [4] 
    % Jumlah TRUE ( > ) data split FASE 2A           [5] 
    % Jumlah FALSE ( > ) data split FASE 2A          [6] 
    % Entropy CHILDREN ( > ) di data split FASE 2A   [7] 
    % Nilai INFO dari setiap data split 2A           [8] 
    % Nilai GAIN dari setiap data split 2A           [9]         
    % ------------------------------------------------------------
%2  % Mencari nilai GAIN (max) dari setiap FITUR:
    % "PC3_18_Best_Split_2A" --> [barisKe,angkaSplit,nilaiGain]            
    % ------------------------------------------------------------
    fase_2A_fix;        
 
    % -------------------------------------------------------------------
%4  % Update kolom pada "PC3_15_Split_1_2B_Split" dengan data training 2B
    % -------------------------------------------------------------------
    % Jumlah TRUE ( <= ) data split FASE 2B          [2] 
    % Jumlah FALSE ( <= ) data split FASE 2B         [3] 
    % Entropy CHILDREN ( <= ) di data split FASE 2B  [4] 
    % Jumlah TRUE ( > ) data split FASE 2B           [5] 
    % Jumlah FALSE ( > ) data split FASE 2B          [6] 
    % Entropy CHILDREN ( > ) di data split FASE 2B   [7] 
    % Nilai INFO dari setiap data split 2B           [8] 
    % Nilai GAIN dari setiap data split 2B           [9]           
    % ------------------------------------------------------------
%5  % Mencari nilai GAIN (max) dari setiap FOLD dan FITUR:
    % "PC3_19_Best_Split_2B" --> [barisKe,angkaSplit,nilaiGain]                                
    % ------------------------------------------------------------
    fase_2B_fix;                         
    
    % -----------------------------------------------------------------------
    % Transformasi data NUMERIK ke HEXA berdasarkan BEST split 1, 2A, dan 2B
    % -----------------------------------------------------------------------
    % Alasan konversi ke HEXA, agar bisa menghilangkan redundansi
    % Kalau ke string, ketika diimplementasi fungsi unique datanya jadi 4
    % saja yaitu 00, 01, 10, dan 11
    % Kalau ke biner, sulit, karena ada cell di dalam cell, jadi perlu effort lebih menghilangkan redundansi
    
        
    % ---------------
    % NUMERIK to HEXA
    % ---------------
    for iFitur = 1 : 37
        for iBaris = 1 : jmlData % Banyaknya data training               
            
            trainingSekarang = PC3_04_DataFitur{1,iFitur}(iBaris,1);
            kelasnya = PC3_04_DataFitur{1,iFitur}(iBaris,2);                    
            split1 = PC3_08_BEST_Split_1{1,iFitur}(1,2);
            split2A = PC3_18_BEST_Split_2A{1,iFitur}(1,2);
                    
            % -----------------------------------------------------------------
            % Mencegah ambil best split 2B kalau memang nilainya tidak ada = []
            % -----------------------------------------------------------------
            if length(PC3_19_BEST_Split_2B{1, iFitur}) ~= 0                                    
                split2B = PC3_19_BEST_Split_2B{1, iFitur}(1,2);      
            end    
                
            %------------------------------------------------------------------------------
            % Proses BINING, kalau "data numerik awal" <= "BEST split 1" maka termasuk "2A"
            %------------------------------------------------------------------------------
            if trainingSekarang <= split1 % <= split 1
                % -----------
                % <= split 2A
                % -----------
                if trainingSekarang <= split2A 
                    PC3_20_Hexa_2(iBaris,iFitur) = 0;
                % ----------
                % > split 2A
                % ----------
                else PC3_20_Hexa_2(iBaris,iFitur) = 1;
                end  
            %--------------------------------------------------------------
            % Kalau "data numerik awal" > "BEST split 1" maka termasuk "2B"
            %--------------------------------------------------------------
            else % > split 1
                % -----------
                % <= split 2B
                % -----------
                if trainingSekarang <= split2B                      
                    PC3_20_Hexa_2(iBaris,iFitur) = 2;
                % ----------
                % > split 2B
                % ----------
                else PC3_20_Hexa_2(iBaris,iFitur) = 3;                               
                end                             
            end 
                
            % --------------------------------------------
            % Menambahkan kolom kelas pada "PC3_20_Hexa_2"
            % --------------------------------------------
            if iFitur == 37 % nambahin kelas                                      
                PC3_20_Hexa_2(iBaris,38) = kelasnya;
                PC3_20_Hexa_2(iBaris,39) = iBaris;                    
            end                 
        end % iFitur                
    end % iBaris                        
                                                                                                                                                                            
    % -------------------------------------
    % Remove redundansi HEXA incldude kelas
    % -------------------------------------
    PC3_21_Hexa_2_Unique = unique(PC3_20_Hexa_2(:,1:38),'rows');      
                            
    % ---------------------------------------------------------
    % Cari perbandingan Unique HEX dengan kelas DAN tanpa kelas
    % ---------------------------------------------------------
    uniqueHEXdenganKelas = length(PC3_21_Hexa_2_Unique); % jumlah unique dengan kelasnya juga
    uniqueHEXtanpaKelas = length(unique(PC3_21_Hexa_2_Unique(:,1:37),'rows')); % Data unique tanpa kelas
    if  uniqueHEXdenganKelas ~= uniqueHEXtanpaKelas % Data unique tanpa kelas ~= data unique                         
        
        % ----------------------------------------------------------------------------
        % Perbandingan jumlah unique DENGAN dan TANPA kelas di "PC3_10_Biner_1_Unique"
        % ----------------------------------------------------------------------------
        PC3_22_Perbandingan_2 = [uniqueHEXtanpaKelas uniqueHEXdenganKelas uniqueHEXdenganKelas-uniqueHEXtanpaKelas];
        
        % ----------------------------------------------------------------------
        % Transformasi data training (NUMERIK) ke BINER dan HEXA dari EBD 2 FASE
        % ----------------------------------------------------------------------
        for iKolomFold = 1 : 37
            for iBaris = 1 : jmlData % Banyaknya data training
                for iFitur = 1 : 37  
                    
                    trainingSekarang = PC3_04_DataFitur{1,iFitur}(iBaris,1);
                    kelasnya = PC3_04_DataFitur{1,iFitur}(iBaris,2);                    
                    split1 = PC3_08_BEST_Split_1{1,iFitur}(1,2);
                    split2A = PC3_18_BEST_Split_2A{1,iFitur}(1,2);
                    
                    % -----------------------------------------------------------------
                    % Mencegah ambil best split 2B kalau memang nilainya tidak ada = []
                    % -----------------------------------------------------------------
                    if length(PC3_19_BEST_Split_2B{1, iFitur}) ~= 0
                        split2B = PC3_19_BEST_Split_2B{1, iFitur}(1,2);      
                    end                                                
                    
                    % ---------------------------------------------------
                    % apakah kolom yang ingin dituju? (dijadikan 2 digit)
                    % ---------------------------------------------------
                    if iFitur == iKolomFold 
                        if trainingSekarang <= split1 % <= split 1                            
                            if trainingSekarang <= split2A % <= split 2A                                                                                                   
                                PC3_23_Hexa_2_PerFitur{1,iKolomFold}(iBaris,iFitur) = 0;
                            else % > split 2A                                                                                                
                                PC3_23_Hexa_2_PerFitur{1,iKolomFold}(iBaris,iFitur) = 1;
                            end                            
                        else % > split 1
                            if trainingSekarang <= split2B % <= split 2B
                                PC3_23_Hexa_2_PerFitur{1,iKolomFold}(iBaris,iFitur) = 2;
                            else % > split 2B
                                PC3_23_Hexa_2_PerFitur{1,iKolomFold}(iBaris,iFitur) = 3;
                            end                             
                        end 
                        if iFitur == 37 % nambahin kelas                                                        
                            PC3_23_Hexa_2_PerFitur{1,iKolomFold}(iBaris,38) = kelasnya;
                            PC3_23_Hexa_2_PerFitur{1,iKolomFold}(iBaris,39) = iBaris;                            
                        end 
                    else % Bukan fitur yang dituju
                        if trainingSekarang <= split1 % <= split 1                                                        
                            PC3_23_Hexa_2_PerFitur{1,iKolomFold}(iBaris,iFitur) = 0;
                        else % > split 1
                            PC3_23_Hexa_2_PerFitur{1,iKolomFold}(iBaris,iFitur) = 1;                            
                        end                        
                        if iFitur == 37 % nambahin kelas                            
                            PC3_23_Hexa_2_PerFitur{1,iKolomFold}(iBaris,38) = kelasnya;
                            PC3_23_Hexa_2_PerFitur{1,iKolomFold}(iBaris,39) = iBaris;                            
                        end                        
                    end % iFitur == iKolomFold                    
                end % iFitur                
            end % iBaris                        
            
            % ------------------------------------------------
            % Remove redundansi biner di EBD 2 FASE pake kelas
            % ------------------------------------------------
            PC3_24_Hexa_2_PerFitur_Unique{1,iKolomFold} = unique(PC3_23_Hexa_2_PerFitur{1,iKolomFold}(:,1:38),'rows');                      
            
            % ---------------------------------------------------------
            % Cari perbandingan Unique HEX dengan kelas DAN tanpa kelas
            % ---------------------------------------------------------
            uniqueHEXfiturDenganKelas = length(PC3_24_Hexa_2_PerFitur_Unique{1,iKolomFold}); % jumlah unique dengan kelasnya juga
            uniqueHEXfiturTanpaKelas = length(unique(PC3_24_Hexa_2_PerFitur_Unique{1,iKolomFold}(:,1:37),'rows')); % Data unique tanpa kelas
            if  uniqueHEXfiturDenganKelas ~= uniqueHEXfiturTanpaKelas % Data unique tanpa kelas ~= data unique                  
                selisih = uniqueHEXfiturDenganKelas - uniqueHEXfiturTanpaKelas;
                PC3_25_Perbandingan_2_PerFitur{1,iKolomFold} = [uniqueHEXfiturTanpaKelas uniqueHEXfiturDenganKelas selisih];  
                kumpulanSelisih(iKolomFold,1) = selisih;                
            else
                disp('Tidak ada redundansi EBD Fase 2 per Fitur!');
            end                         
        end %iKolomFold    
        
        % -------------------------------------------------------------------------
        % Di sini harusnya ada split 3 FASE dst. hingga tidak ada lagi over-vitting
        % -------------------------------------------------------------------------
        %
        %

    else disp('Tidak ada redundansi EBD Fase 2!');
    end                
    
else disp('Tidak ada redundansi EBD Fase 1!');
%---
end

% ------------------------------------------------------------
% Hitung rata-rata selisih di "PC3_25_Perbandingan_2_PerFitur"
% ------------------------------------------------------------
PC3_26_Average_Selisih_PerFitur = mean(kumpulanSelisih);
   
clear iJumlahTF jmlFalse jmlTrue jmlData entropyParent iDataPecah iFiturPecah;
clear dataPertama dataKedua iDataSplit iFiturSplit;
clear dataASC dataSplit iBarisASC iBarisSplit iKolomUpdate;
clear jmlFalseKurang jmlFalseLebih jmlTrueKurang jmlTrueLebih kelasASC;
clear entropyChildKurang piFalseKurang piTrueKurang totalKurang;
clear entropyChildLebih piFalseLebih piTrueLebih totalLebih;
clear angkaBestSplit BarisKe dataChildKurang dataChildLebih GAINinfo INFOsplit Nilai;
clear bestSplit dataAwal dataKelasnya iBarisDiskrit iKolomDiskrit;
clear uniqueDenganKelas uniqueTanpaKelas;
clear A B bestSplit_1 dataSplit_1 iBarisData ikolomFoldSplit jmlSplitDist;
clear hasilSplit2A iBaris2A iKolomFold2A jumlah2A nilaiBestSplit;
clear hasilSplit2B iBaris2B iKolomFold2B jumlah2B nilai2B;
clear dataBestSplit iBarisTraining iKolomTraining numerikAwal;
clear angkaSplitA BarisKeA dataChildKurangA dataChildLebihA dataKelasA dataSplitA dataTrainingA;
clear entropyChildKurangA entropyChildLebihA GAINinfoA iBarisSplitA iBarisTrainingA iKolomCellA INFOsplitA;
clear jmlFalseKurangA jmlFalseLebihA jmlTrueKurangA jmlTrueLebihA NilaiA panjangSplit2A panjangTraining2A;
clear piFalseKurangA piFalseLebihA piTrueKurangA piTrueLebihA totalKurangA totalLebihA;
clear angkaSplitB BarisKeB dataChildKurangB dataChildLebihB dataKelasB dataSplitB dataTrainingB;
clear entropyChildKurangB entropyChildLebihB GAINinfoB iBarisSplitB iBarisTrainingB iKolomCellB INFOsplitB;
clear jmlFalseKurangB jmlFalseLebihB jmlTrueKurangB jmlTrueLebihB NilaiB panjangSplit2B panjangTraining2B;
clear piFalseKurangB piFalseLebihB piTrueKurangB piTrueLebihB totalKurangB totalLebihB;
clear iBaris iFitur iKolomCell kelasnya split1 split2A split2B trainingSekarang;
clear uniqueHEXdenganKelas uniqueHEXtanpaKelas;
clear iKolomFold uniqueHEXfiturDenganKelas uniqueHEXfiturTanpaKelas selisih kumpulanSelisih;

toc

disp('Saving...');
    tic
        save('02_EBD\PC3_fix.mat');        
    toc
disp('Done!');
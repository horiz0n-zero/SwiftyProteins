//
//  ProteinDataManager.swift
//  SwiftyProteins
//
//  Created by Antoine FEUERSTEIN on 2/6/19.
//  Copyright © 2019 Antoine FEUERSTEIN. All rights reserved.
//

import Foundation
import UIKit

class ProteinDataManager: NSObject {
    
    typealias SuccessClosure = (String, Data) -> ()
    typealias FailureClosure = (Error) -> ()
    typealias ProgressClosure = (String, CGFloat) -> ()
    
    class func getProteinImage(ligand: String) -> URL {
        return URL.init(string: "https://files.rcsb.org/ligands/\(ligand.first!)/\(ligand)/\(ligand)-200.gif")!
    }
    class func getProteinFile(ligand: String) -> URL {
        return URL.init(string: "https://files.rcsb.org/ligands/\(ligand.first!)/\(ligand)/\(ligand)_ideal.pdb")!
    }
    class func getDocumentProteinImage(ligand: String) -> URL {
        return ProteinDataManager.documents.appendingPathComponent(ligand + ".png")
    }
    class func getDocumentProteinFile(ligand: String) -> URL {
        return ProteinDataManager.documents.appendingPathComponent(ligand + ".pdb")
    }
    
    static var proteinFiles: [String: Data] = [:]
    fileprivate static var proteinFileSessions: [String: FileSession] = [:]
    func proteinFile(ligand: String, success: @escaping SuccessClosure, failure: @escaping FailureClosure, progress: @escaping ProgressClosure) {
        if let data = ProteinDataManager.proteinFiles[ligand] {
            return success(ligand, data)
        }
        do {
            let documentFile = ProteinDataManager.getDocumentProteinFile(ligand: ligand)
            let data = try Data.init(contentsOf: documentFile)
            
            ProteinDataManager.proteinFiles[ligand] = data
            return success(ligand, data)
        }
        catch { }
        ProteinDataManager.proteinFileSessions[ligand] = FileSession.init(ligand: ligand, progress: progress, success: success, failure: failure)
    }
    
    static var proteinImages: [String: Data] = [:]
    fileprivate static var proteinImageSessions: [String: FileImageSession] = [:]
    func proteinImage(ligand: String, success: @escaping SuccessClosure, failure: @escaping FailureClosure, progress: @escaping ProgressClosure) {
        if let data = ProteinDataManager.proteinImages[ligand] {
            return success(ligand, data)
        }
        do {
            let documentFile = ProteinDataManager.getDocumentProteinImage(ligand: ligand)
            let data = try Data.init(contentsOf: documentFile)
            
            ProteinDataManager.proteinImages[ligand] = data
            return success(ligand, data)
        }
        catch { }
        ProteinDataManager.proteinImageSessions[ligand] = FileImageSession.init(ligand: ligand, progress: progress, success: success, failure: failure)
    }
    
    override init() {
        super.init()
    }
}

class FileImageSession: NSObject {
    
    let ligand: String
    let progress: ProteinDataManager.ProgressClosure
    let success: ProteinDataManager.SuccessClosure
    let failure: ProteinDataManager.FailureClosure
    var task: URLSessionDownloadTask!
    
    init(ligand: String, progress: @escaping ProteinDataManager.ProgressClosure,
         success: @escaping ProteinDataManager.SuccessClosure,
         failure: @escaping ProteinDataManager.FailureClosure) {
        self.ligand = ligand
        self.progress = progress
        self.success = success
        self.failure = failure
        super.init()
        self.task = URLSession.shared.downloadTask(with: ProteinDataManager.getProteinImage(ligand: ligand), completionHandler: { /*[unowned self]*/ url, _, error in
            if let error = error {
                return self.failure(error)
            }
            if let url = url {
                do {
                    let file = ProteinDataManager.getDocumentProteinImage(ligand: self.ligand)
                    
                    try FileManager.default.moveItem(at: url, to: file)
                    let data = try Data.init(contentsOf: file)
                    
                    ProteinDataManager.proteinImages[ligand] = data
                    return self.success(self.ligand, data)
                }
                catch { return self.failure(error) }
            }
            ProteinDataManager.proteinImageSessions[self.ligand] = nil
        })
        self.task.progress.addObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted), options: .new, context: nil)
        self.task.resume()
    }
    deinit {
        self.task.progress.removeObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if self.task.progress.fractionCompleted > 0 {
            self.progress(self.ligand, CGFloat(self.task.progress.fractionCompleted))
        }
    }
}

class FileSession: NSObject {
    
    let ligand: String
    let progress: ProteinDataManager.ProgressClosure
    let success: ProteinDataManager.SuccessClosure
    let failure: ProteinDataManager.FailureClosure
    var task: URLSessionDownloadTask!
    
    init(ligand: String, progress: @escaping ProteinDataManager.ProgressClosure,
                        success: @escaping ProteinDataManager.SuccessClosure,
                        failure: @escaping ProteinDataManager.FailureClosure) {
        self.ligand = ligand
        self.progress = progress
        self.success = success
        self.failure = failure
        super.init()
        self.task = URLSession.shared.downloadTask(with: ProteinDataManager.getProteinFile(ligand: ligand), completionHandler: { /*[unowned self]*/ url, _, error in
            if let error = error {
                return self.failure(error)
            }
            if let url = url {
                do {
                    let file = ProteinDataManager.getDocumentProteinFile(ligand: self.ligand)
                    
                    try FileManager.default.moveItem(at: url, to: file)
                    let data = try Data.init(contentsOf: file)
                    
                    ProteinDataManager.proteinFiles[ligand] = data
                    return self.success(self.ligand, data)
                }
                catch { return self.failure(error) }
            }
            ProteinDataManager.proteinFileSessions[self.ligand] = nil
        })
        self.task.progress.addObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted), options: .new, context: nil)
        self.task.resume()
    }
    deinit {
        self.task.progress.removeObserver(self, forKeyPath: #keyPath(Progress.fractionCompleted))
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.progress(self.ligand, CGFloat(self.task.progress.fractionCompleted))
    }
}

extension ProteinDataManager {
    
    static let documents: URL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    
    static let ligands: [String] = ["001","011","031","041","04G","083","0AF","0DS","0DX","0E5","0EA","0J0","0JV","0L8","0MC","0MD","0RU","0RY","0RZ","0S0","0T6","0T7","0Z9","10R","10S","10U","11O","11U","12I","12P","12U","13M","13R","13S","13U","140","147","15F","15P","16A","16G","18M","18Q","196","1B0","1C5","1CO","1CY","1E2","1H2","1H3","1HP","1KT","1KU","1KY","1KZ","1MA","1MV","1PE","1PG","1QV","1SZ","1UD","1WJ","1WK","1YO","200","210","22J","22M","233","234","23I","244","272","27E","27G","27H","27J","27K","27L","27M","27N","29N","29O","2AN","2F8","2HP","2MG","2MO","2PE","2RY","2TL","2V4","2WL","2WQ","2WR","2XE","2XG","2XH","2XO","2XR","2YZ","30L","30U","32H","32J","338","369","36Y","372","37V","38D","397","398","3A8","3AW","3BR","3DG","3DR","3E4","3EL","3FG","3GY","3GZ","3H0","3H2","3HA","3HM","3HU","3JP","3JQ","3JR","3MY","3NM","3OM","3PG","3QZ","3SN","3SX","3TI","3TR","3TS","3UH","3XU","40F","40K","418","429","42H","42M","43F","442","444","44B","458","459","45U","46U","480","482","49U","4AA","4AW","4D8","4DB","4FC","4FW","4HM","4IN","4KV","4MQ","4NA","4NL","4TC","4TX","4UX","4UY","4UZ","4V2","4V3","4V5","4VO","4XE","4XF","50U","523","52P","555","5AL","5B5","5B7","5B8","5BR","5CD","5FB","5FW","5GP","5KH","5MB","5MC","5MU","5NU","5OB","5PG","5UC","5UD","5YI","62D","689","697","6AP","6NA","6RG","6UA","6W2","789","795","797","7AP","7DG","7HP","7MG","7YG","833","834","870","880","889","893","8HG","8K6","8LR","8OG","941","965","9DG","9LI","9OH","9PR","A1E","A23","A2E","A2G","A2M","A37","A3P","A48","A74","A8B","A8M","A8N","AAC","AAM","AB1","ABA","ABN","ABU","AC6","AC9","ACA","ACE","ACH","ACP","ACT","ACY","AD4","ADE","ADN","ADP","ADV","ADX","AEJ","AEK","AGA","AGP","AGS","AH0","AHB","AHU","AIH","AIJ","AIT","AIU","AJM","AKG","ALC","ALE","ALF","ALO","ALS","ALY","AMH","AMP","ANC","ANN","ANP","AOM","AON","APC","APG","APR","ARA","ARG","ARL","ASC","ASD","AT1","ATP","AU","AUK","AV2","AVX","AYX","AZG","AZI","AZS","AZZ","B12","B3A","B3D","B3E","B3Q","B49","BA","BAL","BAM","BBU","BBX","BBY","BCL","BCP","BCR","BCT","BE2","BEF","BEN","BER","BG6","BG8","BGC","BGL","BGU","BHG","BHL","BHM","BM6","BMA","BMC","BME","BMM","BMT","BNS","BNZ","BO3","BOA","BOG","BPH","BR","BS1","BS2","BTD","BTN","BU3","BUA","BV1","BV2","BV3","BV4","BVD","BXY","BZI","BZX","C03","C09","C1O","C1Q","C2O","C3F","C6Q","C7J","C7L","C7U","C7W","C8E","C8F","C8M","C8P","CA","CAA","CAC","CAF","CAP","CAT","CB3","CBE","CBJ","CCN","CCS","CD","CDK","CDL","CF2","CF4","CFP","CH6","CHO","CHP","CI2","CIS","CIT","CJZ","CL","CLA","CLR","CM3","CM4","CME","CMO","CMP","CN2","CO","CO2","CO3","COA","COI","CP6","CPC","CPJ","CPK","CPS","CPT","CS","CSD","CSO","CSS","CSX","CTN","CTO","CTP","CU","CU1","CUA","CUR","CXM","CXS","CYN","CYS","CZA","D12","D4P","D75","DAB","DAH","DAL","DAO","DBB","DCQ","DCS","DDE","DDT","DG2","DGD","DGL","DHF","DHI","DIB","DIP","DIX","DIY","DLS","DMB","DMS","DMU","DP8","DPN","DPP","DPR","DR9","DRH","DRJ","DSE","DSN","DST","DTB","DTT","DTU","DTV","DTY","DUZ","DVC","DW2","DXC","DXL","DXO","E10","E12","E20","E4D","EAA","EDO","EED","EES","EI1","EMB","EN5","ENF","ENO","ENX","EOH","EPE","EPH","EPU","ERE","ESA","EST","ETC","ETM","EU","EU3","F","F19","F3S","F6F","F9F","FA7","FAD","FAE","FBP","FBR","FCO","FDA","FE","FE2","FEL","FEO","FER","FES","FFA","FFO","FGA","FHM","FHO","FK1","FLC","FLI","FLN","FLV","FMN","FMP","FMT","FO5","FON","FOO","FP1","FSM","FT1","FT2","FTY","FU2","FUC","FUL","FUM","G05","G1P","G2F","G3A","G3H","G3P","G52","G55","G61","G64","G79","G7G","G89","GA","GA2","GAL","GCP","GCQ","GCS","GDL","GDP","GDU","GEN","GGA","GGD","GHP","GKD","GKE","GL0","GL8","GLA","GLC","GLL","GLO","GLY","GM2","GMP","GND","GNH","GNP","GNT","GOL","GP1","GP4","GPI","GRN","GS1","GSH","GSP","GST","GTP","GTX","GUN","GXL","H2S","H2U","H4B","H64","HAB","HAR","HB1","HBA","HBI","HC2","HC3","HC7","HC9","HCL","HEA","HEC","HED","HEM","HEX","HFT","HG","HG7","HGM","HIS","HJ2","HJ3","HKA","HM6","HMG","HOA","HOM","HOS","HPE","HQQ","HQU","HR7","HRD","HSX","HT7","HTD","HTH","HTO","HTQ","HTY","HUP","HUX","HXA","HXY","HZ3","I13","I3A","I46","I63","ID2","IFP","IGP","IH5","IHD","ILB","ILC","ILE","ILF","ILH","IMD","IMI","IMN","IMP","IMT","IMX","IN8","IN9","INH","INI","IOD","IOG","IOK","IPA","IPE","IPH","IPL","IPR","IPX","IQX","IRG","ISL","ISP","ITE","ITL","ITT","IUM","IYR","J35","J43","J53","J5L","J77","J80","JB1","JC1","JFK","JZA","JZD","JZE","K","K7J","KCX","KDG","KDO","KH1","KIR","KN2","KPG","KWT","L04","L07","L09","L71","L7S","L9Q","L9R","LA","LAC","LAE","LDA","LDP","LEA","LFN","LG1","LH3","LH4","LHG","LI","LK1","LK2","LL3","LL4","LL5","LMG","LMR","LMT","LN1","LOC","LPH","LRG","LUM","LUV","LXB","LXZ","LY9","LYA","LYS","LZ0","M12","M2G","M3R","M49","M5Z","M8E","M8M","MA1","MA2","MA3","MA4","MAA","MAG","MAL","MAN","MAU","MBG","MBN","MBT","MDC","MDF","MDN","ME3","MEC","MER","MES","MF4","MF5","MFB","MFU","MG","MGF","MGR","MHB","MHI","MHO","MI2","MIB","MLA","MLC","MLE","MLI","MLR","MLT","MLU","MLY","MMA","MMC","MMV","MN","MN1","MN2","MN7","MN8","MO7","MOB","MP4","MPD","MPV","MRD","MSE","MSR","MT6","MTB","MU0","MU1","MUI","MUT","MVA","MVC","MYA","MYP","MYR","MYS","N09","N1L","N2C","N4B","N6M","NA","NAB","NAD","NAG","NAI","NAJ","NAP","NCO","NCS","NCY","NDG","NDP","NEP","NEQ","NFZ","NGA","NGZ","NH2","NH4","NI","NIO","NLC","NLE","NLG","NLX","NO","NO3","NOG","NPJ","NPM","NPO","NRQ","NSI","NVA","NX1","NX2","NX3","NX4","NX5","NXV","NXW","NXY","NYB","O","O11","O75","O8M","OBH","OCA","OCS","OCT","ODE","ODT","OEC","OEF","OH","OLA","OLC","OMC","OMG","OMO","OMX","OMY","OMZ","ONL","OPC","ORD","ORN","ORO","ORX","OXY","OZ2","P01","P0E","P16","P1T","P2P","P36","P42","P4O","P4P","P6G","P6L","P8H","P9B","PAF","PAJ","PAL","PAM","PAU","PAZ","PB","PB1","PBS","PBX","PC1","PCA","PCP","PCR","PCT","PD","PDC","PDX","PE2","PE3","PE5","PE6","PE8","PEE","PEF","PEG","PEO","PEP","PER","PEU","PFA","PFB","PFF","PFU","PG4","PGD","PGE","PGO","PHA","PHE","PHK","PHO","PIA","PII","PIK","PIQ","PIZ","PL9","PLC","PLG","PLM","PLP","PLS","PLT","PMJ","PMO","PMV","PNP","PO3","PO4","POP","POQ","PP9","PPV","PQN","PQQ","PRP","PRZ","PS9","PSU","PT","PTE","PTG","PTH","PTI","PTR","PTY","PUT","PVE","PXE","PXP","PXX","PYB","PYJ","PYR","Q21","QHA","QMR","QNO","QPS","QPT","QUI","R3S","R3X","R4G","R8G","RAM","RB","RBF","RCY","RDE","REA","REC","RER","REZ","RF1","RF2","RF3","RHQ","RI2","RIS","RJ1","RJ6","RMB","RMD","RMN","RNR","RPO","RRG","RS3","RS7","RST","RU","RU0","RV1","RX8","S10","S2C","S45","S60","SAH","SAL","SAM","SAR","SAS","SB1","SB3","SBB","SBG","SBR","SBS","SBX","SCH","SCN","SCY","SDS","SEC","SEP","SER","SF4","SGC","SIA","SIG","SIN","SMA","SMM","SMN","SNG","SNS","SO4","SP2","SPM","SPO","SQ","SQD","SR","SRO","ST9","STE","STF","STU","SU0","SUC","SW4","SY9","T08","T21","T3O","T55","T5E","TAR","TB","TBE","TC9","TCE","TDS","TEO","TEU","TF1","TF2","TF3","TF4","TG1","THA","THG","THM","THP","TIY","TJF","TL","TLA","TN1","TNR","TOP","TP8","TP9","TPO","TRC","TRD","TRE","TRP","TRS","TRT","TSL","TSY","TTB","TUL","TUX","TWT","TYD","TYM","TYR","TZT","U1","U10","U5P","UBI","UDP","UMA","UMK","UMP","UMQ","UNK","UNL","UNX","UO1","UPE","UPF","UPG","UQ","URA","URB","URF","UTP","V11","V37","V38","V63","VDX","VJP","VLB","VN4","VO1","VO2","VO4","VU2","VU3","VXL","W07","W12","W14","W23","WBU","WC1","WO4","WRA","WV7","WWV","WWZ","WXV","X0J","X1N","XAN","XCX","XDH","XE","XFW","XSN","XX6","XX7","XY1","XYP","Y8L","YB","YCM","YG","YI2","YI3","YI4","YL3","YR4","YS2","YS3","YS4","YS5","YSD","YSE","YSL","YX0","YYG","ZBR","ZCL","ZLP","ZN","ZTP","ZXG","ZYJ","ZYK","ZZR","ZZS"]
    
}

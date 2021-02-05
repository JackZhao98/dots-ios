//
//  DotsData.swift
//  Dots
//
//  Created by Jack Zhao on 1/9/21.
//

import Foundation

struct DotsData: Identifiable, Codable {
    let id: UUID
    var group: [Int] = []
    var bills: [BillObject] = []
    
    init(id: UUID = UUID(), group: [Int] = [0, 1, 2, 3, 5, 6, 9], bills: [BillObject] = BillObject.sample) {
        self.id = id
        self.group = group
        self.bills = bills
    }
    
    // MARK: Accessors
    // TODO: Get all members:
    func getGroup() -> [Int] {
        return group
    }
    // TODO: Access all paid bills
    func getPaidBills() -> [BillObject] {
        var paidBills: [BillObject] = []
        for curr_bill in self.bills {
            if curr_bill.paid {
                paidBills.append(curr_bill)
                continue
            }
        }
        return paidBills
    }
    
    // TODO: Get all unpaid bills
    func getUnpaidBills() -> [BillObject] {
        var unpaidBills: [BillObject] = []
        for curr_bill in self.bills {
            if !curr_bill.paid {
                unpaidBills.append(curr_bill)
                continue
            }
        }
        return unpaidBills
    }
    
    // TODO: get all bills that are associated with the specified dot index (member)
    func filterBills(associatedWith: Int) -> [BillObject] {
        var associatedBills: [BillObject] = []
        for curr_bill in self.bills {
            if curr_bill.attendees.contains(associatedWith) {
                associatedBills.append(curr_bill)
                continue
            }
        }
        return associatedBills
    }
    
    
    // Bills settlement
    func calculate_settlement() -> [(Int, Int, Double)] {
        var mt = [Double] (repeating: 0.0, count: 10) //master table
        var settlement:[(creditor: Int, debtor: Int, amount: Double)] = [] //list of tuples: (creditor, debtor, amount to be paid)
        
        for curr_bill in self.bills {
            for entry in curr_bill.entries {
                let per_person = (entry.getEntryTotal())/Double (entry.participants.count)
                for i in entry.participants {
                    mt[i] = mt[i] - per_person
                }
            }
            
            mt[curr_bill.initiator] = mt[curr_bill.initiator] + curr_bill.billAmount
        }
        
        var creditors = mt.enumerated().filter {$0.element > 0}.sorted(by: {$0.element > $1.element}) //(creditor, $)
        var debtors = mt.enumerated().filter {$0.element < 0}.sorted(by: {$0.element < $1.element}) //(debtor, $ owed)
        
        var cci = 0 //curr creditor index
        var cdi = 0 //curr debtor index
        
        while cci < creditors.count {
            if creditors[cci].1 < (-1 * debtors[cdi].1) {
                settlement += [(creditor: creditors[cci].0, debtor: debtors[cdi].0, amount: creditors[cci].1)]
                debtors[cdi].1 = debtors[cdi].1 + creditors[cci].1
                cci = cci + 1
            }
            else if creditors[cci].1 > (-1 * debtors[cdi].1) {
                settlement += [(creditor: creditors[cci].0, debtor: debtors[cdi].0, amount: (-1 * debtors[cdi].1))]
                creditors[cci].1 = creditors[cci].1 - (-1 * debtors[cdi].1)
                cdi = cdi + 1
            }
            else {
                settlement += [(creditor: creditors[cci].0, debtor: debtors[cdi].0, amount: creditors[cci].1)]
                cci = cci + 1
                cdi = cdi + 1
            }
        }
        
        return settlement
    }
    
    // MARK: Mutators
    //TODO: add member to group
    mutating func addToGroup(i: Int /* 0-9 */) {
        self.group.append(i)
        self.group.sort()
    }
    
    // TODO: remove a member from group
    mutating func removeFromGroup(i: Int /* 0-9 */) {
        for index in 0...self.group.count-1 {
            if self.group[index] == i {
                self.group.remove(at: index)
                return
            }
        }
    }
    
    //TODO: Clear all bills
    mutating func clearBills() {
        self.bills = []
    }
    
    // TODO: Add new bill
    mutating func addNewBill(bill: BillObject) {
        self.bills.append(bill)
    }
    
    // TODO: Remove bill by id
    mutating func removeBillById(id: UUID) {
        for index in 0...self.bills.count-1 {
            if self.bills[index].id == id {
                self.bills.remove(at: index)
                return
            }
        }
    }
    
}

extension DotsData {
    static var sample: DotsData = DotsData(group: [0, 1, 2, 3, 5, 6, 9], bills: BillObject.sample)
}

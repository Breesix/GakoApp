//
//  DateSlider.swift
//  Breesix
//
//  Created by Rangga Biner on 23/10/24.
//

import SwiftUI

struct DateSlider: View {
    @Binding var selectedDate: Date
    @State private var isShowingDatePicker = false
    @State private var tempDate: Date
    @State private var showFutureDateAlert = false
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        HStack(spacing: 17) {
            Button {
                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22))
                    .foregroundStyle(.buttonPrimaryOnBg)
            }
            
            Button {
                tempDate = selectedDate
                isShowingDatePicker = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                    Text(formatDate(selectedDate))
                }
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.buttonPrimaryOnBgLabel)
                .padding(.vertical, 6)
                .frame(width: 289)
                .background(.green300)
                .cornerRadius(8)
            }
            .sheet(isPresented: $isShowingDatePicker) {
                NavigationView {
                    DatePicker("Select Date",
                              selection: $tempDate,
                              in: ...Date(),
                              displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .padding(.horizontal, 16)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Text("Pilih Tanggal")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .padding(.top, 14)
                                    .padding(.horizontal, 12)
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    isShowingDatePicker = false
                                } label: {
                                    Image(systemName: "xmark")
                                }
                                .padding(.top, 14)
                                .padding(.horizontal, 12)
                            }
                        }
                        .onChange(of: tempDate) {
                            if tempDate > Date() {
                                showFutureDateAlert = true
                                tempDate = selectedDate
                            } else {
                                selectedDate = tempDate
                                isShowingDatePicker = false
                            }
                        }
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            
            Button {
                if isToday {
                    showFutureDateAlert = true
                } else {
                    let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    if nextDate > Date() {
                        showFutureDateAlert = true
                    } else {
                        selectedDate = nextDate
                    }
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 22))
                    .foregroundStyle(isToday ? .gray : .buttonPrimaryOnBg)
            }
            .disabled(isToday)
        }
        .alert("Tidak Bisa Memilih Tanggal", isPresented: $showFutureDateAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Tidak dapat memilih tanggal yang belum terjadi.")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "EEEE, d MMMM ''yy"
        return formatter.string(from: date)
    }
}

#Preview {
    DateSlider(selectedDate: .constant(Date.now))
}

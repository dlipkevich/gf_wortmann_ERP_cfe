﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

&После("ПриКопировании")
Процедура гф_ПриКопировании(ОбъектКопирования)
	// #wortmann {
	// #учет кодов маркировки
	// Галфинд Sakovich 2022/12/23
	гф_IDКороба = "";
	// } #wortmann
КонецПроцедуры

#КонецОбласти

#КонецЕсли
﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
&Вместо("СуществующееЗадание")
Функция гф_СуществующееЗадание()
	
	УстановитьПривилегированныйРежим(Истина);
	
	Возврат ПродолжитьВызов();
	
КонецФункции

#КонецЕсли

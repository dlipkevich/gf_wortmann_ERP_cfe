﻿&НаКлиенте
Процедура ПодтвердитьВыбор(Действие)
	
	СтруктураВозврата = Новый Структура("ДатаЦен,ПроцентСкидки");
	СтруктураВозврата.Вставить("Действие", 		Действие);
	Закрыть(СтруктураВозврата);
	
КонецПроцедуры

&НаКлиенте
Процедура НеУчитыватьБлокироки(Команда)
	
	ПодтвердитьВыбор("НеУчитыватьБлокировки");
	
КонецПроцедуры

&НаКлиенте
Процедура Отменить(Команда)
	
	ПодтвердитьВыбор("Отменить");
	
КонецПроцедуры

&НаКлиенте
Процедура ПродолжитьОтгрузку(Команда)
	
	ПодтвердитьВыбор("ПродолжитьОтгрузкуСПересортом");
	
КонецПроцедуры

&НаКлиенте
Процедура ИсключитьКоробСРасхождениями(Команда)
	
	ПодтвердитьВыбор("ИсключитьКоробСРасхождениями");
	
КонецПроцедуры

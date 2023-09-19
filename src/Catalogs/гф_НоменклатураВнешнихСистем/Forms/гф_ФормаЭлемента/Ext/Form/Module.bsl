﻿&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Не Объект.Ссылка.Пустая() Тогда
		СвойстваНоменклатуры.Очистить();    
		ОтборСвойстваНоменклатуры = РегистрыСведений.гф_ЗначенияСвойствНоменклатурыВнешнейСистемы.СоздатьНаборЗаписей();
		
		ОтборСвойстваНоменклатуры.Отбор.НоменклатураВнешнейСистемы.Использование = Истина;
		ОтборСвойстваНоменклатуры.Отбор.НоменклатураВнешнейСистемы.Значение = Объект.Ссылка;
		ОтборСвойстваНоменклатуры.Прочитать();
		ЗначениеВДанныеФормы(ОтборСвойстваНоменклатуры, СвойстваНоменклатуры);
		
		СвойстваХарактеристик.Очистить();  
		ОтборСвойстваХарактеристик = РегистрыСведений.гф_ЗначенияХарактеристикНоменклатурыВнешнейСистемы.СоздатьНаборЗаписей();
		ОтборСвойстваХарактеристик.Отбор.НоменклатураВнешнейСистемы.Использование = Истина;
		ОтборСвойстваХарактеристик.Отбор.НоменклатураВнешнейСистемы.Значение = Объект.Ссылка;
		ОтборСвойстваХарактеристик.Прочитать(); 
		ЗначениеВДанныеФормы(ОтборСвойстваХарактеристик, СвойстваХарактеристик);
	КонецЕсли;  
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	
	текСсылка = ТекущийОбъект.Ссылка;
	
	СвойстваНоменклатурыЗапись = ДанныеФормыВЗначение(СвойстваНоменклатуры, Тип("РегистрСведенийНаборЗаписей.гф_ЗначенияСвойствНоменклатурыВнешнейСистемы"));
	Если СвойстваНоменклатурыЗапись.Количество() > 0 Тогда
		Для каждого СтрокаЗаписи из СвойстваНоменклатурыЗапись Цикл
			СтрокаЗаписи.НоменклатураВнешнейСистемы = текСсылка;
		КонецЦикла;
	    СвойстваНоменклатурыЗапись.Записать();
	КонецЕсли;
	
	СвойстваХарактеристикЗапись = ДанныеФормыВЗначение(СвойстваХарактеристик, Тип("РегистрСведенийНаборЗаписей.гф_ЗначенияХарактеристикНоменклатурыВнешнейСистемы"));
	Если СвойстваХарактеристикЗапись.Количество() > 0 Тогда
		Для Каждого СтрокаЗаписи из СвойстваХарактеристикЗапись Цикл
			СтрокаЗаписи.НоменклатураВнешнейСистемы = текСсылка;
		КонецЦикла;
		СвойстваХарактеристикЗапись.Записать();
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ТаблицаСвойстваХарактеристикПередОкончаниемРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования, Отказ)
	
	ТекДанные = Элемент.ТекущиеДанные;
	Если Не ЗначениеЗаполнено(ТекДанные.Характеристика) Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю("Укажите характеристику");
		Отказ = Истина;
		ОтменаРедактирования = Истина;
	КонецЕсли;
	
КонецПроцедуры


﻿
#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура КомандаЗапрос(Команда) 
	
	КомандаЗапросНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура КомандаЗапросНаСервере()   
	
	СтрокаXML = Неопределено;
	
	УчетнаяЗапись		= Объект.УчетнаяЗапись;
	ПочтовоеОтправление	= Объект.ПочтовоеОтправление;
	
	Ошибки = Новый Массив;
	
	ОтветМассив = гф_ПочтаРоссии.ПолучитьДанныеОтслеживания(УчетнаяЗапись, ПочтовоеОтправление, Ошибки);
	
	Если Ошибки.Количество() Тогда
		
		Для Каждого Ошибка Из Ошибки Цикл
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Ошибка);
			
		КонецЦикла;	 
		
		Возврат;
		
	КонецЕсли;	    
	
	Объект.История.Очистить();
	
	Для Каждого СтрокаОтвета Из ОтветМассив Цикл
		
		НоваяСтрока = Объект.История.Добавить();
		
		НоваяСтрока.ДатаОперации		= СтрокаОтвета.Операция.Дата;
		НоваяСтрока.Операция			= СтрокаОтвета.Операция.Операция;
		НоваяСтрока.ДеталиОперации		= СтрокаОтвета.Операция.Атрибут;
		НоваяСтрока.КонечнаяОперация	= СтрокаОтвета.Операция.КонечнаяОперация;
		
	КонецЦикла;	
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции   

#КонецОбласти

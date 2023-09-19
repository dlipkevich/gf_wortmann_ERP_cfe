﻿
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Если  ВыборGTIN = "1" Тогда
		УстановитьОбласть0("R1C1:R1C1", "GTIN");
	Иначе
		УстановитьОбласть0("R1C1:R1C1", "Артикул");
	КонецЕсли;     	

КонецПроцедуры

&НаКлиенте
Процедура УстановитьОбласть0(Адрес, Текст)

	ДанныеТабличногоДокумента = Данные;	
	ДанныеТабличногоДокумента.ОтображатьСетку = Истина;
	
	Область = ДанныеТабличногоДокумента.Область(Адрес);
	Область.Текст = Текст;
	Область.РастягиватьПоГоризонтали = Истина;

	Область.ГраницаСверху = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);
	Область.ГраницаСлева = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);
	Область.ГраницаСнизу = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);
	Область.ГраницаСправа = Новый Линия(ТипЛинииЯчейкиТабличногоДокумента.Сплошная, 1);    
	
КонецПроцедуры

&НаКлиенте
Процедура Загрузить(Команда)
	
	СтруктураВыбора = Новый Структура();
	СтруктураВыбора.Вставить("Действие", "ЗаполнениеСпискаОтбора");
	
	Массив = новый Массив;
	КоличествоСтрок = Данные.ВысотаТаблицы;
	
	Для НомерСтроки = 2 По КоличествоСтрок Цикл
		Значение = Данные.Область(НомерСтроки, 1, НомерСтроки, 1).Текст;
		Массив.Добавить(Значение);	
	КонецЦикла;
	
	СтруктураВыбора.Вставить("МассивДанных", Массив);
	
	ОповеститьОВыборе(СтруктураВыбора);

КонецПроцедуры


&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ВыборGTIN = ЭтотОбъект.Параметры.ВыборGTIN;
	
КонецПроцедуры


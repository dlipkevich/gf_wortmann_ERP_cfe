﻿#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область ПрограммныйИнтерфейс
	
#КонецОбласти

#Область ПроцедурыИФункцииПечатиФормы

// Заполняет список команд печати.
//
// Параметры:
//   КомандыПечати - см. УправлениеПечатью.СоздатьКоллекциюКомандПечати
//
Процедура ДобавитьКомандыПечати(КомандыПечати) Экспорт
	
	КомандаПечати = КомандыПечати.Добавить();
	
	КомандаПечати.МенеджерПечати					= "Документ.гф_СпецификацияПокупателя";
	КомандаПечати.Идентификатор						= "СпецификацияПокупателя";
	КомандаПечати.Представление						= "Спецификация покупателя";
	КомандаПечати.ПроверкаПроведенияПередПечатью	= Ложь;
	
КонецПроцедуры

// Сформировать печатные формы объектов
//
// ВХОДЯЩИЕ:
//   ИменаМакетов    - Строка    - Имена макетов, перечисленные через запятую
//   МассивОбъектов  - Массив    - Массив ссылок на объекты которые нужно распечатать
//   ПараметрыПечати - Структура - Структура дополнительных параметров печати.
//
// ИСХОДЯЩИЕ:
//   КоллекцияПечатныхФорм - Таблица значений - Сформированные табличные документы
//   ПараметрыВывода       - Структура        - Параметры сформированных табличных документов.
//
Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "СпецификацияПокупателя") Тогда
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
			КоллекцияПечатныхФорм,
			"СпецификацияПокупателя",
			"Спецификация покупателя",
			СформироватьПечатнуюФормуСпецификацияПокупателя(МассивОбъектов, ОбъектыПечати, ПараметрыПечати));
	КонецЕсли;
	
КонецПроцедуры

Функция СформироватьПечатнуюФормуСпецификацияПокупателя(МассивОбъектов, ОбъектыПечати, ПараметрыПечати) Экспорт
	
	ПроблемыСПринтером = Ложь;

	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.АвтоМасштаб = Истина;
	ТабличныйДокумент.ИмяПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_СПЕЦИФИКАЦИЯПОКУПАТЕЛЯ";
	
	УстановитьПривилегированныйРежим(Истина);
	
	Макет = Документы.гф_СпецификацияПокупателя.ПолучитьМакет("СпецификацияПокупателя");
	
	ПервыйДокумент = Истина;
	
	Для Каждого СсылкаНаДокумент Из МассивОбъектов Цикл
		
		Если ПервыйДокумент Тогда
			
			ПервыйДокумент = Ложь;
			
		Иначе	
			
			ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			
		КонецЕсли;
		
		НомерСтрокиНачало = ТабличныйДокумент.ВысотаТаблицы + 1;
		
		ОбластьЗаголовок	= Макет.ПолучитьОбласть("Заголовок");  
		ОбластьШапка		= Макет.ПолучитьОбласть("Шапка");  
		ОбластьПодвал		= Макет.ПолучитьОбласть("Подвал");  
		
		ДанныеДляПечати = ПолучитьДанныеДляПечатиСпецификацияПокупателя(СсылкаНаДокумент);
		
		ФормированиеПечатныхФорм.ВывестиЛоготипВТабличныйДокумент(Макет, ОбластьЗаголовок, "ОбластьЗаголовок", ДанныеДляПечати.ДанныеШапки.Организация);
		
		Пока ДанныеДляПечати.НесколькоЦен.Следующий() Цикл
			
			СтрокаСообщения = "На артикул " + ДанныеДляПечати.НесколькоЦен.Артикул + " в документах";
			
			ВыборкаЗаказов = ДанныеДляПечати.НесколькоЦен.Выбрать();
			
			Первый = Истина;
			
			Пока ВыборкаЗаказов.Следующий() Цикл
				
				СтрокаСообщения = СтрокаСообщения + ?(Первый, " ", ", ") + ВыборкаЗаказов.ПредставлениеЗаказа;
				
				Первый = Ложь;
				
			КонецЦикла;	
			
			СтрокаСообщения = СтрокаСообщения + " обнаружены разные цены.";
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(СтрокаСообщения);
				
		КонецЦикла;	
		
		ЗаполнитьЗначенияСвойств(ОбластьЗаголовок.Параметры, ДанныеДляПечати.ДанныеШапки);
		
		ТабличныйДокумент.Вывести(ОбластьЗаголовок);  
		
		Подвал = Новый ТабличныйДокумент();
		
		ЗаполнитьЗначенияСвойств(ОбластьПодвал.Параметры, ДанныеДляПечати.ДанныеШапки);
		
		Подвал.Вывести(ОбластьПодвал);
		
		ТабличныйДокумент.Вывести(ОбластьШапка);   
		
		НомерПоследнейСтроки = ДанныеДляПечати.ДанныеТабличнойЧасти.Количество();
		НомерСтроки			 = 0;
		НомерСтрокиПП		 = 0;
		
		Для Каждого СтрокаДокумента ИЗ ДанныеДляПечати.ДанныеТабличнойЧасти Цикл
			
			Если Не ЗначениеЗаполнено(СтрокаДокумента.ПредставлениеЗаказа) Тогда
				
				Продолжить;
				
			КонецЕсли;	
			
			Если Не ЗначениеЗаполнено(СтрокаДокумента.НоменклатураПредставление) Тогда
				
				ОбластьСтрока = Макет.ПолучитьОбласть("СтрокаЗаказ");
				
			Иначе	
				
				ОбластьСтрока = Макет.ПолучитьОбласть("Строка");
			
				НомерСтрокиПП = НомерСтрокиПП + 1;
				
				ОбластьСтрока.Параметры.НомерСтрокиПП = НомерСтрокиПП;
				
			КонецЕсли;	
			
			НомерСтроки = НомерСтроки + 1;
			
			ЗаполнитьЗначенияСвойств(ОбластьСтрока.Параметры, СтрокаДокумента);  
			
			МассивПроверяемыхТаблиц = Новый Массив;         
			
			МассивПроверяемыхТаблиц.Добавить(ОбластьСтрока);
			
			Если НомерСтроки = НомерПоследнейСтроки Тогда
				
				МассивПроверяемыхТаблиц.Добавить(Подвал);
				
			КонецЕсли;                    
			
			Попытка
				
				Если Не ТабличныйДокумент.ПроверитьВывод(МассивПроверяемыхТаблиц) Тогда
					
					ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
					
					ТабличныйДокумент.Вывести(ОбластьШапка);   
					
				КонецЕсли;
				
			Исключение   
				
				ПроблемыСПринтером = Истина;
				
			КонецПопытки;
			
			ТабличныйДокумент.Вывести(ОбластьСтрока);
			
		КонецЦикла;	
		
		ТабличныйДокумент.Вывести(Подвал);  
		
		УправлениеПечатью.ЗадатьОбластьПечатиДокумента(
		ТабличныйДокумент,
		НомерСтрокиНачало,
		ОбъектыПечати,
		СсылкаНаДокумент);

	КонецЦикла;
	
	УстановитьПривилегированныйРежим(Ложь);     
	
	Если ПроблемыСПринтером Тогда
		
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не удалось определить высоту страницы. Возможно в системе не установлен принтер.");
		
	КонецЕсли;
	
	Возврат ТабличныйДокумент;
	
КонецФункции     

Функция ПолучитьДанныеДляПечатиСпецификацияПокупателя(СсылкаНаДокумент)
	
	Запрос = Новый Запрос();
	
	Запрос.Текст = "ВЫБРАТЬ ПЕРВЫЕ 1
	|	&ТекущаяДата КАК ТекущаяДата,
	|	гф_СпецификацияПокупателя.Номер КАК Номер,
	|	гф_СпецификацияПокупателя.Дата КАК Дата,
	|	гф_СпецификацияПокупателя.Организация КАК Организация,
	|	гф_СпецификацияПокупателя.Контрагент КАК Контрагент,
	|	гф_СпецификацияПокупателя.Договор КАК Договор,
	|	гф_СпецификацияПокупателя.Ответственный КАК Ответственный,
	|	ВЫРАЗИТЬ(гф_СпецификацияПокупателя.Комментарий КАК СТРОКА(100)) КАК Комментарий,
	|	Организации.Представление КАК ОрганизацияПредставление,
	|	Контрагенты.Представление КАК КонтрагентПредставление,
	|	ДоговорыКонтрагентов.Дата КАК ДатаДоговора,
	|	ДоговорыКонтрагентов.Номер КАК НомерДоговора,
	|	ДоговорыКонтрагентов.Представление КАК ДоговорПредставление,
	|	ВидыЦен.Ссылка КАК ВидЦен,
	|	гф_СпецификацияПокупателя.Ссылка КАК Спецификация
	|ПОМЕСТИТЬ ВТ_Шапка
	|ИЗ
	|	Документ.гф_СпецификацияПокупателя КАК гф_СпецификацияПокупателя
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ВидыЦен КАК ВидыЦен
	|			ПО ДоговорыКонтрагентов.ВидЦенПродажи = ВидыЦен.Ссылка
	|		ПО гф_СпецификацияПокупателя.Договор = ДоговорыКонтрагентов.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Контрагенты КАК Контрагенты
	|		ПО гф_СпецификацияПокупателя.Контрагент = Контрагенты.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Организации КАК Организации
	|		ПО гф_СпецификацияПокупателя.Организация = Организации.Ссылка
	|ГДЕ
	|	гф_СпецификацияПокупателя.Ссылка = &СсылкаНаДокумент
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Контрагенты.Представление КАК ИмяКлиента,
	|	ЗаказыКлиентов.Ссылка КАК Заказ,
	|	ЗаказыКлиентов.Номер КАК НомерЗаказа,
	|	ЗаказыКлиентов.Дата КАК ДатаЗаказа,
	|	ЗаказыКлиентов.Представление КАК ПредставлениеЗаказа,
	|	ЗаказыТовары.Номенклатура КАК Номенклатура,
	|	ЗаказыТовары.Номенклатура.НаименованиеПолное КАК НоменклатураПредставление,
	|	ЗаказыТовары.ДатаОтгрузки КАК ДатаОтгрузки,
	|	ВЫБОР
	|		КОГДА ЗаказыТовары.КоличествоУпаковок = 0
	|			ТОГДА ЗаказыТовары.Количество
	|		ИНАЧЕ ЗаказыТовары.Количество / ЗаказыТовары.КоличествоУпаковок
	|	КОНЕЦ КАК КоличествоВУпаковке,
	|	СУММА(ЗаказыТовары.Количество) КАК Количество,
	|	СУММА(ЗаказыТовары.КоличествоУпаковок) КАК КоличествоУпаковок,
	|	ВЫРАЗИТЬ(ЗаказыТовары.Цена * (1 - ЗаказыТовары.ПроцентРучнойСкидки / 100) * (1 - ЗаказыТовары.ПроцентАвтоматическойСкидки / 100) КАК ЧИСЛО(15, 0)) КАК Цена,
	|	ВЫРАЗИТЬ(ВЫБОР
	|			КОГДА ЗаказыТовары.КоличествоУпаковок = 0
	|				ТОГДА ЗаказыТовары.Цена * (1 - ЗаказыТовары.ПроцентРучнойСкидки / 100) * (1 - ЗаказыТовары.ПроцентАвтоматическойСкидки / 100)
	|			ИНАЧЕ ЗаказыТовары.Цена * (1 - ЗаказыТовары.ПроцентРучнойСкидки / 100) * (1 - ЗаказыТовары.ПроцентАвтоматическойСкидки / 100) * ЗаказыТовары.Количество / ЗаказыТовары.КоличествоУпаковок
	|		КОНЕЦ КАК ЧИСЛО(15, 0)) КАК ЦенаЗаКороб,
	|	НоменклатураСправочник.Артикул КАК Артикул,
	|	НоменклатураСправочник.ЕдиницаДляОтчетов КАК ЕдиницаДляОтчетов,
	|	ЗаказыТовары.СтавкаНДС КАК СтавкаНДС,
	|	ЕСТЬNULL(СтавкиНДС.Ставка, 0) КАК СтавкаНДСЧисло,
	|	Договоры.Ссылка КАК Договор,
	|	ВТ_Шапка.ВидЦен КАК ВидЦен,
	|	ВТ_Шапка.Спецификация КАК Спецификация
	|ПОМЕСТИТЬ ВТ_Номенклатура
	|ИЗ
	|	ВТ_Шапка КАК ВТ_Шапка
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.гф_СпецификацияПокупателя.ЗаказыКлиентов КАК СпецификацияТовары
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента.Товары КАК ЗаказыТовары
	|				ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК НоменклатураСправочник
	|				ПО ЗаказыТовары.Номенклатура = НоменклатураСправочник.Ссылка
	|				ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СтавкиНДС КАК СтавкиНДС
	|				ПО ЗаказыТовары.СтавкаНДС = СтавкиНДС.Ссылка
	|			ПО СпецификацияТовары.ЗаказКлиента = ЗаказыТовары.Ссылка
	|			ВНУТРЕННЕЕ СОЕДИНЕНИЕ Документ.ЗаказКлиента КАК ЗаказыКлиентов
	|				ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Контрагенты КАК Контрагенты
	|				ПО ЗаказыКлиентов.Контрагент = Контрагенты.Ссылка
	|			ПО СпецификацияТовары.ЗаказКлиента = ЗаказыКлиентов.Ссылка
	|		ПО ВТ_Шапка.Спецификация = СпецификацияТовары.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ДоговорыКонтрагентов КАК Договоры
	|		ПО ВТ_Шапка.Договор = Договоры.Ссылка
	|ГДЕ
	|	СпецификацияТовары.Ссылка = &СсылкаНаДокумент
	|
	|СГРУППИРОВАТЬ ПО
	|	ЗаказыКлиентов.Ссылка,
	|	ЗаказыТовары.СтавкаНДС,
	|	НоменклатураСправочник.ЕдиницаДляОтчетов,
	|	НоменклатураСправочник.Артикул,
	|	ЗаказыТовары.ДатаОтгрузки,
	|	Договоры.Ссылка,
	|	ЗаказыТовары.Номенклатура,
	|	Контрагенты.Представление,
	|	ЗаказыКлиентов.Номер,
	|	ЗаказыКлиентов.Дата,
	|	ЗаказыКлиентов.Представление,
	|	ЗаказыТовары.Номенклатура.НаименованиеПолное,
	|	ВЫБОР
	|		КОГДА ЗаказыТовары.КоличествоУпаковок = 0
	|			ТОГДА ЗаказыТовары.Количество
	|		ИНАЧЕ ЗаказыТовары.Количество / ЗаказыТовары.КоличествоУпаковок
	|	КОНЕЦ,
	|	ВЫРАЗИТЬ(ВЫБОР
	|			КОГДА ЗаказыТовары.КоличествоУпаковок = 0
	|				ТОГДА ЗаказыТовары.Цена * (1 - ЗаказыТовары.ПроцентРучнойСкидки / 100) * (1 - ЗаказыТовары.ПроцентАвтоматическойСкидки / 100)
	|			ИНАЧЕ ЗаказыТовары.Цена * (1 - ЗаказыТовары.ПроцентРучнойСкидки / 100) * (1 - ЗаказыТовары.ПроцентАвтоматическойСкидки / 100) * ЗаказыТовары.Количество / ЗаказыТовары.КоличествоУпаковок
	|		КОНЕЦ КАК ЧИСЛО(15, 0)),
	|	ВЫРАЗИТЬ(ЗаказыТовары.Цена * (1 - ЗаказыТовары.ПроцентРучнойСкидки / 100) * (1 - ЗаказыТовары.ПроцентАвтоматическойСкидки / 100) КАК ЧИСЛО(15, 0)),
	|	ЕСТЬNULL(СтавкиНДС.Ставка, 0),
	|	ВТ_Шапка.ВидЦен,
	|	ВТ_Шапка.Спецификация
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_Номенклатура.ИмяКлиента КАК ИмяКлиента,
	|	ВТ_Номенклатура.Заказ КАК Заказ,
	|	ВТ_Номенклатура.НомерЗаказа КАК НомерЗаказа,
	|	ВТ_Номенклатура.ДатаЗаказа КАК ДатаЗаказа,
	|	ВТ_Номенклатура.ПредставлениеЗаказа КАК ПредставлениеЗаказа,
	|	ВТ_Номенклатура.Номенклатура КАК Номенклатура,
	|	ВТ_Номенклатура.НоменклатураПредставление КАК НоменклатураПредставление,
	|	ВТ_Номенклатура.ДатаОтгрузки КАК ДатаОтгрузки,
	|	ВТ_Номенклатура.КоличествоВУпаковке КАК КоличествоВУпаковке,
	|	ВТ_Номенклатура.Количество КАК Количество,
	|	ВТ_Номенклатура.КоличествоУпаковок КАК КоличествоУпаковок,
	|	ВТ_Номенклатура.Цена КАК Цена,
	|	ВТ_Номенклатура.ЦенаЗаКороб КАК ЦенаЗаКороб,
	|	ВТ_Номенклатура.Артикул КАК Артикул,
	|	ВТ_Номенклатура.ЕдиницаДляОтчетов КАК ЕдиницаДляОтчетов,
	|	ВТ_Номенклатура.СтавкаНДС КАК СтавкаНДС,
	|	ВТ_Номенклатура.СтавкаНДСЧисло КАК СтавкаНДСЧисло,
	|	ВТ_Номенклатура.Договор КАК Договор,
	|	ВТ_Номенклатура.ВидЦен КАК ВидЦен,
	|	ЕСТЬNULL(ЦеныНоменклатуры25СрезПоследних.Цена, 0) КАК РекомендованнаяРозничнаяЦена,
	|	ВЫРАЗИТЬ(ВТ_Номенклатура.Цена * ВТ_Номенклатура.Количество * ВТ_Номенклатура.СтавкаНДСЧисло / 100 КАК ЧИСЛО(15, 0)) КАК СуммаНДС,
	|	ВТ_Номенклатура.Цена * ВТ_Номенклатура.Количество + (ВЫРАЗИТЬ(ВТ_Номенклатура.Цена * ВТ_Номенклатура.Количество * ВТ_Номенклатура.СтавкаНДСЧисло / 100 КАК ЧИСЛО(15, 0))) КАК СуммаСНДС,
	|	ВТ_Номенклатура.Спецификация КАК Спецификация
	|ПОМЕСТИТЬ ВТ_НоменклатураСуммы
	|ИЗ
	|	ВТ_Номенклатура КАК ВТ_Номенклатура
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныНоменклатуры25.СрезПоследних(
	|				&МоментВремени,
	|				(Номенклатура, ВидЦены) В
	|					(ВЫБРАТЬ РАЗЛИЧНЫЕ
	|						Т.Номенклатура,
	|						Т.ВидЦен
	|					ИЗ
	|						ВТ_Номенклатура КАК Т)) КАК ЦеныНоменклатуры25СрезПоследних
	|		ПО ВТ_Номенклатура.Номенклатура = ЦеныНоменклатуры25СрезПоследних.Номенклатура
	|			И ВТ_Номенклатура.ВидЦен = ЦеныНоменклатуры25СрезПоследних.ВидЦены
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Подзапрос.Артикул КАК Артикул,
	|	ВТ_Номенклатура.ПредставлениеЗаказа КАК ПредставлениеЗаказа
	|ИЗ
	|	(ВЫБРАТЬ
	|		ВЫБОР
	|			КОГДА ВТ_Номенклатура.Артикул = """"
	|				ТОГДА ВТ_Номенклатура.НоменклатураПредставление
	|			ИНАЧЕ ВТ_Номенклатура.Артикул
	|		КОНЕЦ КАК Артикул,
	|		КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ВТ_Номенклатура.Цена) КАК КоличествоРазныхЦен
	|	ИЗ
	|		ВТ_Номенклатура КАК ВТ_Номенклатура
	|	
	|	СГРУППИРОВАТЬ ПО
	|		ВЫБОР
	|			КОГДА ВТ_Номенклатура.Артикул = """"
	|				ТОГДА ВТ_Номенклатура.НоменклатураПредставление
	|			ИНАЧЕ ВТ_Номенклатура.Артикул
	|		КОНЕЦ) КАК Подзапрос
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Номенклатура КАК ВТ_Номенклатура
	|		ПО Подзапрос.Артикул = ВТ_Номенклатура.Артикул
	|ГДЕ
	|	Подзапрос.КоличествоРазныхЦен > 1
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Подзапрос.Артикул,
	|	ВТ_Номенклатура.ПредставлениеЗаказа
	|ИЗ
	|	(ВЫБРАТЬ
	|		ВЫБОР
	|			КОГДА ВТ_Номенклатура.Артикул = """"
	|				ТОГДА ВТ_Номенклатура.НоменклатураПредставление
	|			ИНАЧЕ ВТ_Номенклатура.Артикул
	|		КОНЕЦ КАК Артикул,
	|		КОЛИЧЕСТВО(РАЗЛИЧНЫЕ ВТ_Номенклатура.Цена) КАК КоличествоРазныхЦен
	|	ИЗ
	|		ВТ_Номенклатура КАК ВТ_Номенклатура
	|	
	|	СГРУППИРОВАТЬ ПО
	|		ВЫБОР
	|			КОГДА ВТ_Номенклатура.Артикул = """"
	|				ТОГДА ВТ_Номенклатура.НоменклатураПредставление
	|			ИНАЧЕ ВТ_Номенклатура.Артикул
	|		КОНЕЦ) КАК Подзапрос
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ВТ_Номенклатура КАК ВТ_Номенклатура
	|		ПО Подзапрос.Артикул = ВТ_Номенклатура.НоменклатураПредставление
	|ГДЕ
	|	Подзапрос.КоличествоРазныхЦен > 1
	|ИТОГИ ПО
	|	Артикул
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_Шапка.ТекущаяДата КАК ТекущаяДата,
	|	ВТ_Шапка.Номер КАК Номер,
	|	ВТ_Шапка.Дата КАК Дата,
	|	ВТ_Шапка.Организация КАК Организация,
	|	ВТ_Шапка.Организация КАК Грузоотправитель,
	|	ВТ_Шапка.Контрагент КАК Контрагент,
	|	ВТ_Шапка.Контрагент КАК Грузополучатель,
	|	ВТ_Шапка.Договор КАК Договор,
	|	ВТ_Шапка.Ответственный КАК Ответственный,
	|	ВТ_Шапка.Комментарий КАК Комментарий,
	|	ВТ_Шапка.ОрганизацияПредставление КАК ОрганизацияПредставление,
	|	ВТ_Шапка.КонтрагентПредставление КАК КонтрагентПредставление,
	|	ВТ_Шапка.ДатаДоговора КАК ДатаДоговора,
	|	ВТ_Шапка.НомерДоговора КАК НомерДоговора,
	|	ВТ_Шапка.ДоговорПредставление КАК ДоговорПредставление,
	|	ВТ_Шапка.ВидЦен КАК ВидЦен,
	|	ВТ_Шапка.Спецификация КАК Спецификация,
	|	СУММА(ВТ_НоменклатураСуммы.Количество) КАК Количество,
	|	СУММА(ВТ_НоменклатураСуммы.КоличествоУпаковок) КАК КоличествоУпаковок,
	|	СУММА(ВТ_НоменклатураСуммы.СуммаНДС) КАК СуммаНДС,
	|	СУММА(ВТ_НоменклатураСуммы.СуммаСНДС) КАК СуммаСНДС
	|ИЗ
	|	ВТ_Шапка КАК ВТ_Шапка
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_НоменклатураСуммы КАК ВТ_НоменклатураСуммы
	|		ПО ВТ_Шапка.Спецификация = ВТ_НоменклатураСуммы.Спецификация
	|
	|СГРУППИРОВАТЬ ПО
	|	ВТ_Шапка.ВидЦен,
	|	ВТ_Шапка.ТекущаяДата,
	|	ВТ_Шапка.НомерДоговора,
	|	ВТ_Шапка.Договор,
	|	ВТ_Шапка.ДатаДоговора,
	|	ВТ_Шапка.Комментарий,
	|	ВТ_Шапка.КонтрагентПредставление,
	|	ВТ_Шапка.ДоговорПредставление,
	|	ВТ_Шапка.ОрганизацияПредставление,
	|	ВТ_Шапка.Организация,
	|	ВТ_Шапка.Контрагент,
	|	ВТ_Шапка.Дата,
	|	ВТ_Шапка.Спецификация,
	|	ВТ_Шапка.Ответственный,
	|	ВТ_Шапка.Номер
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_НоменклатураСуммы.ИмяКлиента КАК ИмяКлиента,
	|	ВТ_НоменклатураСуммы.Заказ КАК Заказ,
	|	ВТ_НоменклатураСуммы.НомерЗаказа КАК НомерЗаказа,
	|	ВТ_НоменклатураСуммы.ДатаЗаказа КАК ДатаЗаказа,
	|	ВТ_НоменклатураСуммы.ПредставлениеЗаказа КАК ПредставлениеЗаказа,
	|	ВТ_НоменклатураСуммы.Номенклатура КАК Номенклатура,
	|	ВТ_НоменклатураСуммы.НоменклатураПредставление КАК НоменклатураПредставление,
	|	ВТ_НоменклатураСуммы.ДатаОтгрузки КАК ДатаОтгрузки,
	|	ВТ_НоменклатураСуммы.КоличествоВУпаковке КАК КоличествоВУпаковке,
	|	ВТ_НоменклатураСуммы.Количество КАК Количество,
	|	ВТ_НоменклатураСуммы.КоличествоУпаковок КАК КоличествоУпаковок,
	|	ВТ_НоменклатураСуммы.Цена КАК Цена,
	|	ВТ_НоменклатураСуммы.ЦенаЗаКороб КАК ЦенаЗаКороб,
	|	ВТ_НоменклатураСуммы.Артикул КАК Артикул,
	|	ВТ_НоменклатураСуммы.ЕдиницаДляОтчетов КАК ЕдиницаДляОтчетов,
	|	ВТ_НоменклатураСуммы.СтавкаНДС КАК СтавкаНДС,
	|	ВТ_НоменклатураСуммы.СтавкаНДСЧисло КАК СтавкаНДСЧисло,
	|	ВТ_НоменклатураСуммы.Договор КАК Договор,
	|	ВТ_НоменклатураСуммы.ВидЦен КАК ВидЦен,
	|	ВТ_НоменклатураСуммы.РекомендованнаяРозничнаяЦена КАК РекомендованнаяРозничнаяЦена,
	|	ВТ_НоменклатураСуммы.СуммаНДС КАК СуммаНДС,
	|	ВТ_НоменклатураСуммы.СуммаСНДС КАК СуммаСНДС,
	|	ВТ_НоменклатураСуммы.Спецификация КАК Спецификация
	|ИЗ
	|	ВТ_НоменклатураСуммы КАК ВТ_НоменклатураСуммы
	
	|УПОРЯДОЧИТЬ ПО
	|	ИмяКлиента,
	|	ПредставлениеЗаказа,
	|	НоменклатураПредставление
	|ИТОГИ ПО
	|	ИмяКлиента,
	|	ПредставлениеЗаказа";
	
	Запрос.Параметры.Вставить("СсылкаНаДокумент", СсылкаНаДокумент);   
	Запрос.Параметры.Вставить("МоментВремени", СсылкаНаДокумент.МоментВремени());   
	Запрос.Параметры.Вставить("ТекущаяДата", ТекущаяДата());   
	
	Результаты = Запрос.ВыполнитьПакет();
	
	РазмерМассиваРезультатов = Результаты.Количество();
	
	СмещениеДублейЦен		= 3;
	СмещениеШапки			= 2;
	СмещениеТабличнойЧасти	= 1;
	
	ИндексДублейЦен			= РазмерМассиваРезультатов - СмещениеДублейЦен;
	ИндексШапки				= РазмерМассиваРезультатов - СмещениеШапки;
	ИндексТабличнойЧасти	= РазмерМассиваРезультатов - СмещениеТабличнойЧасти;
	
	ДанныеШапки = Новый Структура;
	
	ТаблицаШапки = Результаты[ИндексШапки].Выгрузить();
	
	СтрокаШапки = ТаблицаШапки[0];
	
	Для Каждого Колонка Из ТаблицаШапки.Колонки Цикл 
		
		ДанныеШапки.Вставить(Колонка.Имя,СтрокаШапки[Колонка.Имя]);
		
	КонецЦикла;	   
	
	ДанныеШапки.Вставить("ЗаголовокСпецификации", "Спецификация № " + ДанныеШапки.Номер + " от " + Формат(ДанныеШапки.Дата,"ДФ=dd.MM.yyyy"));
	ДанныеШапки.Вставить("СуммаПрописью", ЧислоПрописью(ДанныеШапки.СуммаСНДС,"Л=ru_RU; ДП=Ложь","рубль, рубля, рублей, м, копейка, копейки, копеек, ж"));
	
	СведенияОПоставщике = ФормированиеПечатныхФорм.СведенияОЮрФизЛице(ДанныеШапки.Организация, ДанныеШапки.Дата);
	
	ДанныеШапки.Вставить("Банк");
	ДанныеШапки.Вставить("БИК");
	ДанныеШапки.Вставить("КоррСчет");
	ДанныеШапки.Вставить("НомерСчета");
	ДанныеШапки.Вставить("ИНН");
	ДанныеШапки.Вставить("КПП");
	ДанныеШапки.Вставить("НаименованиеДляПечатныхФорм");
	
	ЗаполнитьЗначенияСвойств(ДанныеШапки, СведенияОПоставщике);  
	
	
	ДанныеШапки.Вставить("ПредставлениеПоставщика", 
		ФормированиеПечатныхФорм.ОписаниеОрганизации(ФормированиеПечатныхФорм.СведенияОЮрФизЛице(ДанныеШапки.Организация, ДанныеШапки.Дата),
			"ПолноеНаименование,ИНН,КПП,ЮридическийАдрес,Телефоны,"));
	
	ДанныеШапки.Вставить("ПредставлениеПолучателя", 
		ФормированиеПечатныхФорм.ОписаниеОрганизации(ФормированиеПечатныхФорм.СведенияОЮрФизЛице(ДанныеШапки.Контрагент, ДанныеШапки.Дата),
			"ПолноеНаименование,ИНН,КПП,ЮридическийАдрес,Телефоны,"));
	
	ДанныеШапки.Вставить("ПредставлениеГрузоотправителя", 
		ФормированиеПечатныхФорм.ОписаниеОрганизации(ФормированиеПечатныхФорм.СведенияОЮрФизЛице(ДанныеШапки.Организация, ДанныеШапки.Дата),
			"ПолноеНаименование,ИНН,КПП,ЮридическийАдрес,Телефоны,"));
	
	ДанныеШапки.Вставить("ПредставлениеГрузополучателя", 
		ФормированиеПечатныхФорм.ОписаниеОрганизации(ФормированиеПечатныхФорм.СведенияОЮрФизЛице(ДанныеШапки.Контрагент, ДанныеШапки.Дата),
			"ПолноеНаименование,ИНН,КПП,ЮридическийАдрес,Телефоны,"));

	ОтветственныеЛица = ОтветственныеЛицаСервер.ПолучитьОтветственныеЛицаОрганизации(ДанныеШапки.Организация);

	ДанныеШапки.Вставить("ФИОРуководителя", ФизическиеЛицаУТ.ФамилияИнициалыФизЛица(ОтветственныеЛица.Руководитель));
	ДанныеШапки.Вставить("РуководительДолжность", ФизическиеЛицаУТ.ФамилияИнициалыФизЛица(ОтветственныеЛица.РуководительДолжность));
	ДанныеШапки.Вставить("ФИОБухгалтера", ФизическиеЛицаУТ.ФамилияИнициалыФизЛица(ОтветственныеЛица.ГлавныйБухгалтер));

		
	НесколькоЦен			= Результаты[ИндексДублейЦен].Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	ДанныеТабличнойЧасти	= Результаты[ИндексТабличнойЧасти].Выгрузить();
	
	Для Каждого СтрокаТовара Из ДанныеТабличнойЧасти Цикл   
		
		Если СтрокаТовара.Номенклатура = Null Тогда
			
			Продолжить;
			
		КонецЕсли;	
		
		ДнейВВисокосномГоду			= 366;    
		НомерДня28Февраля			= 59;
		КонецПервойПоловиныМесяца	= 14;
		НачалоВторойПоловиныМесяца	= КонецПервойПоловиныМесяца + 1;
		
		Если ДеньГода(КонецГода(СтрокаТовара.ДатаОтгрузки)) = ДнейВВисокосномГоду И ДеньГода(СтрокаТовара.ДатаОтгрузки) = НомерДня28Февраля Тогда
			
			ДатаОтгрузки = КонецМесяца(СтрокаТовара.ДатаОтгрузки);   
			
		Иначе	
			
			ДатаОтгрузки = СтрокаТовара.ДатаОтгрузки;   
			
		КонецЕсли;	
		
		Если ДатаОтгрузки = КонецМесяца(ДатаОтгрузки) Тогда
			
			СтрокаТовара.НоменклатураПредставление = СтрокаТовара.НоменклатураПредставление
			+ " (" + Формат(Дата(Год(ДатаОтгрузки), Месяц(ДатаОтгрузки), НачалоВторойПоловиныМесяца), "ДФ=dd.MM.yyyy")
			+ " - "	+ Формат(ДатаОтгрузки, "ДФ=dd.MM.yyyy")	+ ")";
			
		ИначеЕсли День(ДатаОтгрузки) = НачалоВторойПоловиныМесяца Тогда
			
			СтрокаТовара.НоменклатураПредставление = СтрокаТовара.НоменклатураПредставление
			+ " (" + Формат(НачалоМесяца(ДатаОтгрузки), "ДФ=dd.MM.yyyy")
			+ " - "	+ Формат(ДатаОтгрузки, "ДФ=dd.MM.yyyy")	+ ")";
			
		КонецЕсли;	  
		
		СтрокаТовара.ПредставлениеЗаказа = СтрокаТовара.НомерЗаказа + " от " + Формат(СтрокаТовара.ДатаЗаказа, "ДФ=dd.MM.yyyy"); 
		
	КонецЦикла;	
	
	Результат = Новый Структура("ДанныеШапки, ДанныеТабличнойЧасти, НесколькоЦен", ДанныеШапки, ДанныеТабличнойЧасти, НесколькоЦен);
	
	Возврат Результат;
	
КонецФункции	

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#КонецОбласти

#КонецЕсли

﻿
// Запускает процедуру обмена с сайтом.
// Параметры
//  УзелОбмена - Ссылка на план обмена с сайтом.
//  РежимЗапускаОбмена - строка - поясняющая был ли обмен запущен интерактивно
//						или через регл. задание.
//  ВыгружатьТолькоИзменения - Булево - определяет будут выгружаться все данные
// 						или только зарегистрированные.
&Вместо ("ВыполнитьОбмен")
Процедура B2B_ВыполнитьОбмен(УзелОбмена, РежимЗапускаОбмена, ВыгружатьТолькоИзменения = Истина, ПараметрыОбновления = Неопределено) Экспорт
	
	Отказ = Ложь;
	ОписаниеОшибки = "";
	
	// Перед обменом необходимо убедиться что есть доступ на сайт или к каталогу.
	ТекстСообщения = "";
	СвойстваНастройки = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(УзелОбмена, 
		"ВыгружатьНаСайт, ФайлЗагрузки, КаталогВыгрузки, ОбменТоварами, ОбменЗаказами,
		|РазмерПорции, КоличествоПовторений, ВладелецКаталога, ОбменЗаказами, ОбменТоварами, ВидОтбораПоНоменклатуре,
		|ВыгружатьКартинки, ВыгружатьТовары, ВыгружатьЦеныОстатки, ВыгружатьОбновленияЦенИОстатков, ВыгружатьФайлыБезОжиданияПодтвержденияИмпортаСервером,
		|ВыполнятьОбменБезИдентификатораСессии, ОграничитьКаталогДоступнымиПредложениями");
	Если СвойстваНастройки.ВыгружатьНаСайт Тогда
		
		Если Не УзелОбмена.B2B_ОбменJSON Тогда
			ДоступноПодключениеКСайту = Ложь;
			
			ПроверитьПодключениеКСайту(ДоступноПодключениеКСайту, УзелОбмена, ТекстСообщения);
			Если Не ДоступноПодключениеКСайту Тогда
				
				ЗаписьЖурналаРегистрации(НСтр("ru = 'Обмен с сайтами';
												|en = 'Exchange with sites'", ОбщегоНазначения.КодОсновногоЯзыка()),
					УровеньЖурналаРегистрации.Предупреждение,
					УзелОбмена.Метаданные(),
					УзелОбмена,
					ТекстСообщения + " " + НСтр("ru = 'Обмен отменен.';
												|en = 'The exchange has been canceled.'"));
				
				ОбщегоНазначения.СообщитьПользователю(ТекстСообщения);
				
				Возврат;
				
			КонецЕсли;
		КонецЕсли;
		
	Иначе
		
		Отказ = Ложь;
		Если СвойстваНастройки.ОбменТоварами Тогда
			ТекстСообщения = "";

			КаталогВыгрузки = СвойстваНастройки.КаталогВыгрузки;
			КаталогДоступен = Ложь;
			ПроверитьДоступностьКаталогаВыгрузки(КаталогДоступен, КаталогВыгрузки, ТекстСообщения);
			Если Не КаталогДоступен Тогда
				
				ЗаписьЖурналаРегистрации(НСтр("ru = 'Обмен с сайтами';
												|en = 'Exchange with sites'", ОбщегоНазначения.КодОсновногоЯзыка()),
				УровеньЖурналаРегистрации.Предупреждение,
				УзелОбмена.Метаданные(),
				УзелОбмена,
				ТекстСообщения + " " + НСтр("ru = 'Обмен отменен.';
											|en = 'The exchange has been canceled.'"));
				
				ОбщегоНазначения.СообщитьПользователю(ТекстСообщения);
				
				Отказ = Истина;
				
			КонецЕсли;
		КонецЕсли;
		
		Если СвойстваНастройки.ОбменЗаказами Тогда
			ТекстСообщения = "";

			ФайлЗагрузки = СвойстваНастройки.ФайлЗагрузки;
			ФайлЗагрузкиДоступен = Истина;
			ПроверитьДоступностьФайлаЗагрузки(ФайлЗагрузкиДоступен, ФайлЗагрузки, ТекстСообщения);
			Если Не ФайлЗагрузкиДоступен Тогда
				
				ЗаписьЖурналаРегистрации(НСтр("ru = 'Обмен с сайтами';
												|en = 'Exchange with sites'", ОбщегоНазначения.КодОсновногоЯзыка()),
					УровеньЖурналаРегистрации.Предупреждение,
					УзелОбмена.Метаданные(),
					УзелОбмена,
					ТекстСообщения + " " + НСтр("ru = 'Обмен отменен.';
												|en = 'The exchange has been canceled.'"));
				
				ОбщегоНазначения.СообщитьПользователю(ТекстСообщения);
				
				Отказ = Истина;
				
			КонецЕсли;
			
		КонецЕсли;
		
		Если Отказ Тогда
			Возврат;
		КонецЕсли;
		
	КонецЕсли;
	
	ТаблицаИнформации = РегистрыСведений.СостоянияОбменовССайтом.СоздатьНаборЗаписей().Выгрузить();
	ТаблицаИнформации.Колонки.Добавить("Описание", Новый ОписаниеТипов("Строка"));
	
	НастройкиПодключения = Новый Структура;
	ЗаполнитьНастройкиПодключения(НастройкиПодключения, УзелОбмена);
	
	РазрешенныеТипыКартинок = Новый Массив;
	РазрешенныеТипыКартинок.Добавить("gif");
	РазрешенныеТипыКартинок.Добавить("jpg");
	РазрешенныеТипыКартинок.Добавить("jpeg");
	РазрешенныеТипыКартинок.Добавить("png");

	
	ПараметрыОбмена = Новый Структура;
	ПараметрыОбмена.Вставить("УзелОбмена", УзелОбмена);
	ПараметрыОбмена.Вставить("НастройкиПодключения", НастройкиПодключения);
	
	Если ВыгружатьТолькоИзменения Тогда
		ВыгружатьИзменения = УзелОбмена.ВыгружатьИзменения;
	Иначе
		ВыгружатьИзменения = Ложь;
	КонецЕсли;
	ПараметрыОбмена.Вставить("ВыгружатьИзменения", ВыгружатьИзменения);
	
	ПараметрыОбмена.Вставить("ВидОтбораПоНоменклатуре", СвойстваНастройки.ВидОтбораПоНоменклатуре);
	ПараметрыОбмена.Вставить("РазмерПорции", СвойстваНастройки.РазмерПорции);
	ПараметрыОбмена.Вставить("КоличествоПовторов",СвойстваНастройки.КоличествоПовторений);
	ПараметрыОбмена.Вставить("ВладелецКаталога", СвойстваНастройки.ВладелецКаталога);
	ПараметрыОбмена.Вставить("ОбменЗаказами", СвойстваНастройки.ОбменЗаказами);
	ПараметрыОбмена.Вставить("ОбменТоварами", СвойстваНастройки.ОбменТоварами);
	
	ПараметрыОбмена.Вставить("ВыгружатьТовары", СвойстваНастройки.ВыгружатьТовары);
	ПараметрыОбмена.Вставить("ВыгружатьЦеныОстатки", СвойстваНастройки.ВыгружатьЦеныОстатки);
	ПараметрыОбмена.Вставить("ВыгружатьОбновленияЦенИОстатков", СвойстваНастройки.ВыгружатьОбновленияЦенИОстатков);
	
	ПараметрыОбмена.Вставить("КаталогВыгрузки", СвойстваНастройки.КаталогВыгрузки);
	ПараметрыОбмена.Вставить("ВыгружатьНаСайт", СвойстваНастройки.ВыгружатьНаСайт);
	ПараметрыОбмена.Вставить("ВыгружатьКартинки", СвойстваНастройки.ВыгружатьКартинки);
	ПараметрыОбмена.Вставить("ВыгружатьФайлыБезОжиданияПодтвержденияИмпортаСервером", СвойстваНастройки.ВыгружатьФайлыБезОжиданияПодтвержденияИмпортаСервером);
	ПараметрыОбмена.Вставить("ИспользоватьИдентификаторСессии", Не СвойстваНастройки.ВыполнятьОбменБезИдентификатораСессии);
	ПараметрыОбмена.Вставить("ОграничитьКаталогДоступнымиПредложениями", СвойстваНастройки.ОграничитьКаталогДоступнымиПредложениями);

	ПараметрыОбмена.Вставить("РазрешенныеТипыКартинок",РазрешенныеТипыКартинок);
	ПараметрыОбмена.Вставить("НаименованиеНалога", НСтр("ru = 'НДС';
														|en = 'VAT'"));
	
	ИспользоватьХарактеристики = Истина;
	
	ОбменССайтомПереопределяемый.УстановитьПризнакИспользоватьХарактеристики(ИспользоватьХарактеристики);
	ПараметрыОбмена.Вставить("ИспользоватьХарактеристики", ИспользоватьХарактеристики);
	
	ПараметрыОбмена.Вставить("РежимЗапускаОбмена", РежимЗапускаОбмена);
	
	ПрикладныеПараметры = ПараметрыПрикладногоРешения(УзелОбмена);
	
	ПараметрыОбмена.Вставить("ПрикладныеПараметры", ПрикладныеПараметры);
	
	ФайлЗагрузки = УзелОбмена.ФайлЗагрузки;
	ФайлЗагрузки = ОбменССайтом.ПодготовитьПутьДляПлатформы(ОбменССайтом.ПлатформаWindows(), ФайлЗагрузки);
	
	ПараметрыОбмена.Вставить("ФайлЗагрузки", ФайлЗагрузки);
	
	ПараметрыОбмена.Вставить("МассивКаталогов", Новый Массив);
	ПараметрыОбмена.Вставить("ДанныеОЗаказах", Неопределено);
	
	СтруктураИзменений = Новый Структура;
	СтруктураИзменений.Вставить("Заказы", Новый Массив);
	Если ВыгружатьТолькоИзменения Тогда
		СтруктураИзменений.Вставить("Товары", Новый Массив);
	КонецЕсли;
	ПолучитьИзмененияУзла(СтруктураИзменений, УзелОбмена);
	
	ПараметрыОбмена.Вставить("СтруктураИзменений",СтруктураИзменений);
	
	ОбменССайтомПереопределяемый.ИзменитьПараметрыОбмена(ПараметрыОбмена, УзелОбмена);
	
	РезультатОбмена = Новый Структура;
	
	ОбменССайтом.ВыполнитьОбменССайтом(ПараметрыОбмена, РезультатОбмена, ТаблицаИнформации);
	
	Ошибка = (Не РезультатОбмена.ТоварыВыгружены) Или (Не РезультатОбмена.ВыполненОбменЗаказами);
	
	Если ПараметрыОбмена.Свойство("СтруктураСтатистики")
		И ПараметрыОбмена.СтруктураСтатистики.Загружено.Количество() > 0 Тогда
		ИмяДокументаЗаказ = ОбменССайтомПовтИсп.ИмяПрикладногоДокумента("ЗаказПокупателя");
		Если Не ИмяДокументаЗаказ = Неопределено Тогда
			ПараметрыОбновления.Обновить = Истина;
			ПараметрыОбновления.ИмяДокументаЗаказ = ИмяДокументаЗаказ;
		КонецЕсли;
	КонецЕсли;
	
	ВыполнитьДействияПриЗавершенииОбмена(ПараметрыОбмена, ТаблицаИнформации, Ошибка);
	
КонецПроцедуры

// Выборочно регистрирует изменения для узлов плана обмена с сайтом.
//
// Параметры:
//	Объект		- Объект метаданных - источник события
//	Замещение - режим записи набора записей регистра.
//
&Вместо ("ЗарегистрироватьИзменения")
Процедура B2B_ЗарегистрироватьИзменения(Объект, Замещение = Ложь)
	
	Если ПолучитьФункциональнуюОпцию("ИспользоватьОбменССайтом") = Ложь
		Или Объект.ДополнительныеСвойства.Свойство("ОтключитьМеханизмРегистрацииОбъектов") Тогда 
			
		Возврат;
		
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	ТипОбъекта = ТипЗнч(Объект);
	
	МассивНоменклатуры = Новый Массив;
	
	Если ТипОбъекта = Тип("СправочникОбъект.Номенклатура") Тогда
		
		МассивНоменклатуры.Добавить(Объект.Ссылка);
		
	ИначеЕсли ТипОбъекта = Тип("СправочникОбъект.НоменклатураПрисоединенныеФайлы") 
		И ТипЗнч(Объект.ВладелецФайла) = Тип("СправочникСсылка.Номенклатура") Тогда
		
		МассивНоменклатуры.Добавить(Объект.ВладелецФайла);

		
	ИначеЕсли ТипОбъекта = Тип("СправочникОбъект.ХарактеристикиНоменклатуры")
		И ТипЗнч(Объект.Владелец) = Тип("СправочникСсылка.Номенклатура") Тогда
		
		МассивНоменклатуры.Добавить(Объект.Владелец);
		
	ИначеЕсли ТипОбъекта = Тип("РегистрНакопленияНаборЗаписей.гф_ДвижениеКодовМаркировкиОрганизации")
		Или ТипОбъекта = Тип("РегистрСведенийНаборЗаписей.ЦеныНоменклатуры")
		Или ТипОбъекта = Тип("РегистрСведенийНаборЗаписей.ЦеныНоменклатуры25")
		Или ТипОбъекта = Тип("РегистрСведенийНаборЗаписей.ДополнительныеСведения") Тогда
		
		Если Замещение Тогда
			
			ОбъектМетаданных = Объект.Метаданные();
			ИмяРегистра = ОбъектМетаданных.Имя; 
			
			ИмяБазовогоТипа = ОбщегоНазначения.ИмяБазовогоТипаПоОбъектуМетаданных(ОбъектМетаданных);
			
			СтарыйНаборЗаписей = Неопределено;
			Если ИмяБазовогоТипа = "РегистрыСведений" Тогда
				СтарыйНаборЗаписей = РегистрыСведений[ОбъектМетаданных.Имя].СоздатьНаборЗаписей();
			ИначеЕсли ИмяБазовогоТипа = "РегистрыНакопления" Тогда
				СтарыйНаборЗаписей = РегистрыНакопления[ОбъектМетаданных.Имя].СоздатьНаборЗаписей();
			КонецЕсли;
			
			Если СтарыйНаборЗаписей <> Неопределено Тогда
				
				Для Каждого ЗначениеОтбора Из Объект.Отбор Цикл
					
					Если ЗначениеОтбора.Использование = Ложь Тогда
						Продолжить;
					КонецЕсли;
					
					СтрокаОтбора = СтарыйНаборЗаписей.Отбор.Найти(ЗначениеОтбора.Имя);
					СтрокаОтбора.Значение = ЗначениеОтбора.Значение;
					СтрокаОтбора.Использование = Истина;
					
				КонецЦикла;
				
				СтарыйНаборЗаписей.Прочитать();
				
				ВыбратьНоменклатуруИзЗаписейРегистра(ИмяРегистра, СтарыйНаборЗаписей, МассивНоменклатуры);
				
			КонецЕсли;
			
		КонецЕсли;
		
		ВыбратьНоменклатуруИзЗаписейРегистра(ИмяРегистра, Объект, МассивНоменклатуры);
		
	КонецЕсли;
	
	ЗарегистрироватьИзмененияНоменклатурыВУзлах(МассивНоменклатуры);
	
КонецПроцедуры 

Процедура ВыбратьНоменклатуруИзЗаписейРегистра(ИмяРегистра, НаборЗаписей, МассивНоменклатуры)
	
	Для каждого Запись Из НаборЗаписей Цикл 
		
		Если ИмяРегистра = "гф_ДвижениеКодовМаркировкиОрганизации" Тогда
			Номенклатура = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Запись.КМ, "Номенклатура");
			
		ИначеЕсли ИмяРегистра = "ДополнительныеСведения" Тогда 
			
			Номенклатура = Запись.Объект; 
			
			Если ТипЗнч(Номенклатура) <> Тип("СправочникСсылка.Номенклатура") Тогда
				Продолжить;	
			КонецЕсли; 
			
		Иначе
			Номенклатура = Запись.Номенклатура;	
		КонецЕсли;
			
		Если ЗначениеЗаполнено(Номенклатура) И МассивНоменклатуры.Найти(Номенклатура) = Неопределено Тогда
			МассивНоменклатуры.Добавить(Номенклатура);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗарегистрироватьИзмененияНоменклатурыВУзлах(МассивНоменклатуры)
	
	Если Не ЗначениеЗаполнено(МассивНоменклатуры) Тогда
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СправочникНоменклатура.Ссылка КАК Номенклатура,
	|	СправочникНоменклатура.B2B_Портал КАК B2B_Портал
	|ПОМЕСТИТЬ ВтНоменклатураИПорталы
	|ИЗ
	|	Справочник.Номенклатура КАК СправочникНоменклатура
	|
	|ГДЕ
	|	СправочникНоменклатура.Ссылка В(&МассивНоменклатуры)
	|	И НЕ СправочникНоменклатура.ЭтоГруппа
	|	И СправочникНоменклатура.B2B_Портал <> ЗНАЧЕНИЕ(Справочник.B2B_Портал.ПустаяСсылка) 
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ 
	|	СправочникНоменклатура.Ссылка КАК Номенклатура,
	|	СведенияОПортале.Значение КАК B2B_Портал
	|ИЗ
	|	Справочник.Номенклатура КАК СправочникНоменклатура
	|	
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК СведенияОПортале
    |			ПО СправочникНоменклатура.Ссылка = СведенияОПортале.Объект
	|		    	И СведенияОПортале.Свойство = &Свойство_B2B_Портал
	|
	|ГДЕ
	|	СправочникНоменклатура.Ссылка В(&МассивНоменклатуры)
	|	И СправочникНоменклатура.ЭтоГруппа
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	СправочникНоменклатура.Ссылка КАК Номенклатура,
	|	ЗНАЧЕНИЕ(Справочник.B2B_Портал.ПустаяСсылка) КАК B2B_Портал
	|ИЗ
	|	Справочник.Номенклатура КАК СправочникНоменклатура
	|	
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК СведенияВыгружать
    |			ПО СправочникНоменклатура.Ссылка = СведенияВыгружать.Объект
	|		    	И СведенияВыгружать.Свойство = &Свойство_ВыгружатьНаB2CПортал
	|				И СведенияВыгружать.Значение = ИСТИНА
	|
	|ГДЕ
	|	СправочникНоменклатура.Ссылка В(&МассивНоменклатуры)
	|;
    |
    |////////////////////////////////////////////////////////////////////////////////
    |ВЫБРАТЬ
	|	НоменклатураИПорталы.Номенклатура КАК Номенклатура,
	|	ПланОбмена.Ссылка КАК УзелОбмена
	|ИЗ 
	|	ВтНоменклатураИПорталы КАК НоменклатураИПорталы
	|	
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ПланОбмена.ОбменССайтом КАК ПланОбмена
	|			ПО НоменклатураИПорталы.B2B_Портал = ПланОбмена.B2B_Портал
	|			И НЕ ПланОбмена.ПометкаУдаления
	|			И ПланОбмена.ОбменТоварами
	|			И ПланОбмена.Ссылка <> &ЭтотУзел
	|
	|ИТОГИ ПО
	|	УзелОбмена";
	
	Запрос.УстановитьПараметр("МассивНоменклатуры", МассивНоменклатуры);
	Запрос.УстановитьПараметр("Свойство_ВыгружатьНаB2CПортал", Справочники.B2B_w_Настройки.Свойство_ВыгружатьНаB2CПортал.Значение);
	Запрос.УстановитьПараметр("Свойство_B2B_Портал",           Справочники.B2B_w_Настройки.Свойство_B2B_Портал.Значение);
	Запрос.УстановитьПараметр("ЭтотУзел", ПланыОбмена.ОбменССайтом.ЭтотУзел()); 
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаУзлов = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока ВыборкаУзлов.Следующий() Цикл
		
		МассивНоменклатурыУзла = Новый Массив;
		Выборка = ВыборкаУзлов.Выбрать();
		Пока Выборка.Следующий() Цикл
			МассивНоменклатурыУзла.Добавить(Выборка["Номенклатура"]);
		КонецЦикла;
		
		Если ЗначениеЗаполнено(МассивНоменклатурыУзла) Тогда
			ПланыОбмена.ЗарегистрироватьИзменения(ВыборкаУзлов["УзелОбмена"], МассивНоменклатурыУзла);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура НеИспользуется_ЗарегистрироватьИзменения(Объект, Замещение = Ложь)
	
	Если ПолучитьФункциональнуюОпцию("ИспользоватьОбменССайтом") = Ложь
			Или Объект.ДополнительныеСвойства.Свойство("ОтключитьМеханизмРегистрацииОбъектов") Тогда 
			
		Возврат;
		
	КонецЕсли;
	
	УстановитьПривилегированныйРежим(Истина);
	
	ТипОбъекта = ТипЗнч(Объект);
	//МассивУзловТовары = ОбменССайтомПовтИсп.МассивУзловДляРегистрации(Истина);    
	МассивУзловТовары = B2B_МассивУзловДляРегистрации(Истина);    
	
	//отфильтруем по указанному порталу 
	Если ТипЗнч(Объект) = Тип("СправочникОбъект.Номенклатура") Тогда   
		
		сч = МассивУзловТовары.Количество()-1;
		Пока сч >= 0 Цикл       
			
			Если МассивУзловТовары[сч].B2B_Портал.Пустая() Тогда //это значит B2C портал, здесь регистрируем номенклатуру у которой Допсведение установлено
				регсв = новый Запрос;
				регсв.Текст = "ВЫБРАТЬ
				              |	ДополнительныеСведения.Значение КАК Значение
				              |ИЗ
				              |	РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведения
				              |ГДЕ
				              |	ДополнительныеСведения.Объект = &Объект
				              |	И ДополнительныеСведения.Свойство = &Свойство";
				
				регсв.УстановитьПараметр("Объект",Объект.Ссылка);
				регсв.УстановитьПараметр("Свойство",Справочники.B2B_w_Настройки.Свойство_ВыгружатьНаB2CПортал.Значение);
				рез = регсв.Выполнить().Выбрать();
				Если рез.Следующий() тогда
					Если рез.Значение = Истина Тогда
						//значит регистрируем!
					Иначе                             
						//не регистрируем
						МассивУзловТовары.Удалить(сч);
					КонецЕсли;
				Иначе
					//не регистрируем
					МассивУзловТовары.Удалить(сч);
				КонецЕсли;					
			Иначе
			
				B2B_Портал = Объект.B2B_Портал; 
				
				// vvv Галфинд \ Sakovich 09.01.2024
				// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811eead82b0b09e6c
				// B2B_Портал для группы номенклатуры тут равен Null
				// Если B2B_Портал.Пустая() Тогда
				Если  B2B_Портал = Справочники.B2B_Портал.ПустаяСсылка() Тогда
				// ^^^ Галфинд \ Sakovich 09.01.2024
				
					регсв = новый Запрос;
					регсв.Текст = "ВЫБРАТЬ
					              |	ДополнительныеСведения.Значение КАК Значение
					              |ИЗ
					              |	РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведения
					              |ГДЕ
					              |	ДополнительныеСведения.Объект = &Объект
					              |	И ДополнительныеСведения.Свойство = &Свойство";
					
					регсв.УстановитьПараметр("Объект",Объект.Ссылка);
					регсв.УстановитьПараметр("Свойство",Справочники.B2B_w_Настройки.Свойство_B2B_Портал.Значение);
					рез = регсв.Выполнить().Выбрать();
					Если рез.Следующий() тогда
						B2B_Портал = рез.Значение;
					КонецЕсли;
				КонецЕсли;	
				
				Если (МассивУзловТовары[сч].B2B_Портал <> B2B_Портал) и
					НЕ МассивУзловТовары[сч].B2B_Портал.Пустая() Тогда
					МассивУзловТовары.Удалить(сч);
				КонецЕсли;
			КонецЕсли;
			сч = сч - 1;
		КонецЦикла;   
		Если МассивУзловТовары.Количество() = 0 Тогда
			Возврат;
		КонецЕсли;                                                  
	КонецЕсли;
	//
	
	МассивУзловЗаказы = ОбменССайтомПовтИсп.МассивУзловДляРегистрации(,Истина);
	ОбменССайтомПереопределяемый.ЗарегистрироватьИзмененияВУзлах(Объект, МассивУзловТовары, МассивУзловЗаказы, Замещение);
	
КонецПроцедуры  


Функция B2B_МассивУзловДляРегистрации(ОбменТоварами = Ложь, ОбменЗаказами = Ложь)
	
	МассивУзлов = Новый Массив;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ОбменССайтом.Ссылка КАК Узел
	|ИЗ
	|	ПланОбмена.ОбменССайтом КАК ОбменССайтом
	|ГДЕ
	|	ВЫБОР
	|			КОГДА &ОбменТоварами
	|				ТОГДА ОбменССайтом.ОбменТоварами
	|			КОГДА &ОбменЗаказами
	|				ТОГДА ОбменССайтом.ОбменЗаказами
	|		КОНЕЦ
	|	И НЕ ОбменССайтом.Ссылка = &ЭтотУзел";
	Запрос.УстановитьПараметр("ОбменТоварами", ОбменТоварами);
	Запрос.УстановитьПараметр("ОбменЗаказами", ОбменЗаказами);
	Запрос.УстановитьПараметр("ЭтотУзел", ПланыОбмена.ОбменССайтом.ЭтотУзел());
	Результат = Запрос.Выполнить();
	Выборка = Результат.Выбрать();
	Пока Выборка.Следующий() Цикл
		МассивУзлов.Добавить(Выборка.Узел);
	КонецЦикла;
	
	Возврат МассивУзлов;
	
КонецФункции
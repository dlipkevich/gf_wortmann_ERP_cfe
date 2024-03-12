﻿Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	
	СтруктураТипов = ОбщегоНазначенияУТ.СоответствиеМассивовПоТипамОбъектов(МассивОбъектов);
	
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ЗаказПоставщикуСКартинками") Тогда
		
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		"ЗаказПоставщикуСКартинками",
		НСтр("ru = 'Заказ поставщику с картинками';
		|en = 'Purchase Order with pictures'"),
		СформироватьПечатнуюФормуЗаказПоставщикуСКартинками(МассивОбъектов, СтруктураТипов, ОбъектыПечати, ПараметрыПечати));
		
	КонецЕсли;
	
	Если УправлениеПечатью.НужноПечататьМакет(КоллекцияПечатныхФорм, "ЗаказПоставщикуСКартинкамиРазмеры") Тогда
		
		УправлениеПечатью.ВывестиТабличныйДокументВКоллекцию(
		КоллекцияПечатныхФорм,
		"ЗаказПоставщикуСКартинкамиРазмеры",
		НСтр("ru = 'Заказ поставщику с картинками размеры';
		|en = 'Purchase Order with pictures size'"),
		СформироватьПечатнуюФормуЗаказПоставщикуСКартинкамиРазмеры(МассивОбъектов, СтруктураТипов, ОбъектыПечати, ПараметрыПечати));
		
	КонецЕсли;
	
	ФормированиеПечатныхФорм.ЗаполнитьПараметрыОтправки(ПараметрыВывода.ПараметрыОтправки, СтруктураТипов, КоллекцияПечатныхФорм);
	
КонецПроцедуры

Функция СформироватьПечатнуюФормуЗаказПоставщикуСКартинками(МассивОбъектов, СтруктураТипов, ОбъектыПечати, ПараметрыПечати) Экспорт
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.АвтоМасштаб = Истина;
	ТабличныйДокумент.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
	
	Для Каждого МассивОбъект Из МассивОбъектов Цикл
	
	//МассивДок = Новый Массив;
	//
	//Для Каждого СтруктураОбъектов Из СтруктураТипов Цикл
	//	
	//ОбщегоНазначенияКлиентСервер.ДополнитьМассив(МассивДок, СтруктураОбъектов.Значение);
	//
	//КонецЦикла;
	
	МакетОбработки = ПолучитьМакет("ПФ_MXL_ЗаказПоставщикуСКартинками");
	ОбластьШапка = МакетОбработки.ПолучитьОбласть("Шапка");
	ОбластьСтрока = МакетОбработки.ПолучитьОбласть("Строка");
	ОбластьПодвал = МакетОбработки.ПолучитьОбласть("Подвал");
	
	//ОбластьОписаниеКартинка = МакетОбработки.ПолучитьОбласть("ОписаниеКартинка");
	//ОбластьСтрока.Присоединить(ОбластьОписаниеКартинка);
	
	//Запрос = Новый Запрос;
	//Запрос.Текст =
	//"ВЫБРАТЬ
	//|	ЗаказПоставщику.Ссылка КАК Ссылка,
	//|	ЗаказПоставщику.Номер КАК Номер,
	//|	ЗаказПоставщику.Дата КАК Дата,
	//|	ЗаказПоставщику.Организация КАК Организация,
	//|	ЗаказПоставщику.Контрагент КАК Контрагент,
	//|	ЗаказПоставщику.Товары.(
	//|		Ссылка КАК Ссылка,
	//|		НомерСтроки КАК НомерСтроки,
	//|		НоменклатураПартнера КАК НоменклатураПартнера,
	//|		Номенклатура КАК Номенклатура,
	//|		Характеристика КАК Характеристика,
	//|		Упаковка КАК Упаковка,
	//|		КоличествоУпаковок КАК КоличествоУпаковок,
	//|		Количество КАК Количество,
	//|		ДатаПоступления КАК ДатаПоступления,
	//|		ВидЦеныПоставщика КАК ВидЦеныПоставщика,
	//|		Цена КАК Цена,
	//|		Сумма КАК Сумма,
	//|		ПроцентРучнойСкидки КАК ПроцентРучнойСкидки,
	//|		СуммаРучнойСкидки КАК СуммаРучнойСкидки,
	//|		УдалитьСтавкаНДС КАК УдалитьСтавкаНДС,
	//|		СтавкаНДС КАК СтавкаНДС,
	//|		СуммаНДС КАК СуммаНДС,
	//|		СуммаСНДС КАК СуммаСНДС,
	//|		КодСтроки КАК КодСтроки,
	//|		Отменено КАК Отменено,
	//|		СтатьяРасходов КАК СтатьяРасходов,
	//|		АналитикаРасходов КАК АналитикаРасходов,
	//|		ПричинаОтмены КАК ПричинаОтмены,
	//|		Склад КАК Склад,
	//|		Назначение КАК Назначение,
	//|		Подразделение КАК Подразделение,
	//|		СписатьНаРасходы КАК СписатьНаРасходы,
	//|		ИдентификаторСтроки КАК ИдентификаторСтроки,
	//|		ДатаОтгрузки КАК ДатаОтгрузки
	//|	) КАК Товары,
	//|	ЗаказПоставщику.гф_ПродукцияВКоробах.(
	//|		Ссылка КАК Ссылка,
	//|		НомерСтроки КАК НомерСтроки,
	//|		ВариантКомплектации КАК ВариантКомплектации,
	//|		КоличествоКоробов КАК КоличествоКоробов,
	//|		IDКороба КАК IDКороба,
	//|		СтоимостьКороба КАК СтоимостьКороба,
	//|		НДС КАК НДС,
	//|		Сумма КАК Сумма
	//|	) КАК гф_ПродукцияВКоробах,
	//|	ЗаказПоставщику.СуммаДокумента КАК СуммаДокумента
	//|ИЗ
	//|	Документ.ЗаказПоставщику КАК ЗаказПоставщику
	//|ГДЕ
	//|	ЗаказПоставщику.Ссылка = &Ссылка";
	//Запрос.Параметры.Вставить("Ссылка",МассивДок[0].Ссылка);
	//Таб = Запрос.Выполнить().Выгрузить();
	
	// Заполнение области Шапка
	// Удаление нулей из номера документа
	НомерДок = Прав(МассивОбъект.Номер, 6);
	НомерБезНулей = НомерДок;
	Пока Найти(НомерБезНулей,"0") = 1 Цикл
		НомерБезНулей = Сред(НомерБезНулей,2); //удаляет лидирующие нули
	КонецЦикла;
	//
	ОбластьШапка.Параметры.НомерЗаказа = "Заказ поставщику № " + НомерБезНулей + " от " + Формат(МассивОбъект.Дата, "ДЛФ=ДД");
	ОбластьШапка.Параметры.Поставщик   = МассивОбъект.Организация.Наименование + ", ИНН " + МассивОбъект.Организация.ИНН + ", КПП " + МассивОбъект.Организация.КПП; 
	ОбластьШапка.Параметры.Покупатель  = МассивОбъект.Контрагент.Наименование + ", ИНН " + МассивОбъект.Контрагент.ИНН + ", КПП " + МассивОбъект.Контрагент.КПП;
	ТабличныйДокумент.Вывести(ОбластьШапка);
	//
	ТабличныйДокументКолонки = Новый ТабличныйДокумент;
	ТабличныйДокументЛево    = Новый ТабличныйДокумент;
	ТабличныйДокументЦентр   = Новый ТабличныйДокумент;
	ТабличныйДокументПраво   = Новый ТабличныйДокумент;
	ИтогоКоробов = 0;
	ИтогоПар     = 0;
	//Заполнение области Строка
	НомерСтроки = 1;
	Для Каждого СтрТов Из МассивОбъект.гф_ПродукцияВКоробах Цикл
		
		ОбластьЛево = МакетОбработки.ПолучитьОбласть("СтрокаЛево");
		ТабличныйДокументЛево.Вывести(ОбластьЛево);
		
		ОбластьОписаниеКартинка = МакетОбработки.ПолучитьОбласть("ОписаниеКартинка");
		ТабличныйДокументЦентр.Вывести(ОбластьОписаниеКартинка);
		
		ОбластьПраво = МакетОбработки.ПолучитьОбласть("СтрокаПраво");
		ТабличныйДокументПраво.Вывести(ОбластьПраво);
		
		Пар = 0;
		Для Каждого Стр Из МассивОбъект.Товары Цикл
			
			ОбластьЛево.Параметры.Номер                  = НомерСтроки;
			ОбластьПраво.Параметры.Пар                   = Стр.Номенклатура.ЕдиницаИзмерения.Наименование;
			ОбластьПраво.Параметры.Цена                  = Стр.СуммаСНДС;
			
			Запрос = Новый Запрос;
			Запрос.Текст =
			"ВЫБРАТЬ
			|	Номенклатура.Ссылка КАК Ссылка,
			|	Номенклатура.ФайлКартинки КАК ФайлКартинки
			|ИЗ
			|	Справочник.Номенклатура КАК Номенклатура
			|ГДЕ
			|	Номенклатура.Ссылка = &Ссылка";
			Запрос.Параметры.Вставить("Ссылка",Стр.Номенклатура.Ссылка);
			ТабНоменклатура = Запрос.Выполнить().Выгрузить();
			
			ИтогоПар = ИтогоПар + Стр.Количество;
			Пар =  Пар + Стр.Количество;
			
		КонецЦикла;
		
		Попытка
			УстановитьПривилегированныйРежим(Истина);
			КартинкаНоменклатуры = РаботаСФайлами.ДвоичныеДанныеФайла(ТабНоменклатура[0].ФайлКартинки);
			УстановитьПривилегированныйРежим(Ложь);
		Исключение
			КартинкаНоменклатуры = Неопределено;
		КонецПопытки;
		
		Если ЗначениеЗаполнено(КартинкаНоменклатуры) Тогда
			ОбластьКартинка = ОбластьОписаниеКартинка.Области.АдресКартинки;
			
			Если ТипЗнч(КартинкаНоменклатуры) = Тип("Картинка") Тогда
				ОбластьКартинка.Картинка = КартинкаНоменклатуры;
			ИначеЕсли ТипЗнч(КартинкаНоменклатуры) = Тип("ДвоичныеДанные") Тогда
				КартинкаКарточки = Новый Картинка(КартинкаНоменклатуры);
				
				ОбластьКартинка.Картинка = ?(КартинкаКарточки.Формат() = ФорматКартинки.НеизвестныйФормат,
				Неопределено,
				КартинкаКарточки);
			КонецЕсли;
			
		КонецЕсли;
		
		ХарМин  = 0;
		ХарМакс = 0;
		КолУпак = 0;
		ИндУпак = 0;
		Для Каждого СтрКомпл Из СтрТов.ВариантКомплектации.Товары Цикл
			
			КолУпак = КолУпак + СтрКомпл.Количество;
			Число = Число(СтрКомпл.Характеристика.Наименование);
			Если ИндУпак = 0 Тогда
				
				ХарМин  = Число;
				ХарМакс = Число;
				
			Иначе
				
				Если ХарМин > Число Тогда
					
					ХарМин = Число;
					
				КонецЕсли;
				
				Если ХарМакс < Число Тогда
					
					ХарМакс = Число
					
				КонецЕсли;
				
			КонецЕсли;
			
			ИндУпак = ИндУпак +1;
			
		КонецЦикла;
		
		ОбластьПраво.Параметры.КоличествоПар         = Пар;
		ОбластьПраво.Параметры.Артикул               = СтрТов.ВариантКомплектации.Наименование;
		ОбластьПраво.Параметры.Товар                 = СтрТов.ВариантКомплектации.Владелец.НаименованиеПолное + " (р." + ХарМин + "-" + ХарМакс + "). (" + КолУпак + " пар/кор)";
		//ОбластьПраво.Параметры.Цвет                  = ;
		ОбластьПраво.Параметры.ТорговаяМарка         = СтрТов.ВариантКомплектации.Владелец.Ссылка.Марка.Наименование;
		//ОбластьПраво.Параметры.НаименованиеПодкладки = ;
		//ОбластьПраво.Параметры.СрокПоставки          = ;
		ОбластьПраво.Параметры.КоличествоКоробов     = СтрТов.КоличествоКоробов;
		СчетДляИтого                                 = СтрТов.КоличествоКоробов;
		ОбластьПраво.Параметры.Единица               = СтрТов.ВариантКомплектации.Упаковка.Наименование;
		ОбластьПраво.Параметры.Сумма                 = СтрТов.КоличествоКоробов + СтрТов.СтоимостьКороба;
		
		НомерСтроки = НомерСтроки + 1;
		
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ
		|	ДополнительныеСведения.Объект КАК Объект,
		|	ДополнительныеСведения.Свойство КАК Свойство,
		|	ДополнительныеСведения.Значение КАК Значение
		|ИЗ
		|	РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведения
		|ГДЕ
		|	ДополнительныеСведения.Объект = &Объект";
		Запрос.Параметры.Вставить("Объект",СтрТов.ВариантКомплектации.Владелец);
		Таб = Запрос.Выполнить().Выгрузить();
		
		Если Не Таб.Количество() = 0 Тогда
			Для Каждого СтрЦвет Из Таб Цикл
				Если СтрЦвет.Свойство.Наименование = "Color_Name" Тогда
					ОбластьПраво.Параметры.Цвет = СтрЦвет.Значение;
				КонецЕсли;
				Если СтрЦвет.Свойство.Наименование = "Material warmlining" Тогда
					ОбластьПраво.Параметры.НаименованиеПодкладки = СтрЦвет.Значение;
				КонецЕсли;
				Если СтрЦвет.Свойство.Наименование = "Дата поставки" Тогда
					ОбластьПраво.Параметры.СрокПоставки = Формат(СтрЦвет.Значение, "ДЛФ=Д");
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
		ТабличныйДокумент.Вывести(ОбластьЛево);
		ТабличныйДокумент.Присоединить(ОбластьОписаниеКартинка);
		ТабличныйДокумент.Присоединить(ОбластьПраво);
		
		ИтогоКоробов = ИтогоКоробов + СчетДляИтого;
		
	КонецЦикла;
	//
	ОбластьПодвал.Параметры.ИтогоКоличествоКоробов = ИтогоКоробов;
	ОбластьПодвал.Параметры.ИтогоКоличествоПар     = ИтогоПар;
	ОбластьПодвал.Параметры.ИтогоСумма             = МассивОбъект.СуммаДокумента;
	ОбластьПодвал.Параметры.НаименованийНаСумму = "Всего наименований " + НомерСтроки + " , на сумму " + МассивОбъект.СуммаДокумента + " руб.";
	ОбластьПодвал.Параметры.СуммаПрописью = ЧислоПрописью(МассивОбъект.СуммаДокумента, "Л=ru_RU", "рубль, рубля, рублей, м, копейка, копейки, копеек, ж, 2");
	//ОбластьПодвал.Параметры.Руководитель = ;
	//ОбластьПодвал.Параметры.Бухгалтер = ;
	
	ТабличныйДокумент.Вывести(ОбластьПодвал);
	
	КонецЦикла;
	
	Возврат ТабличныйДокумент;
	
КонецФункции	

Функция СформироватьПечатнуюФормуЗаказПоставщикуСКартинкамиРазмеры(МассивОбъектов, СтруктураТипов, ОбъектыПечати, ПараметрыПечати) Экспорт
	
	ТабличныйДокумент = Новый ТабличныйДокумент;
	ТабличныйДокумент.АвтоМасштаб = Истина;
	ТабличныйДокумент.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
	
	Для Каждого МассивОбъект Из МассивОбъектов Цикл 
	
	//МассивДок = Новый Массив;
	//
	//Для Каждого СтруктураОбъектов Из СтруктураТипов Цикл
	//	
	//ОбщегоНазначенияКлиентСервер.ДополнитьМассив(МассивДок, СтруктураОбъектов.Значение);
	//
	//КонецЦикла;
	
	МакетОбработки = ПолучитьМакет("ПФ_MXL_ЗаказПоставщикуСКартинкамиРазмеры");
	ОбластьШапка = МакетОбработки.ПолучитьОбласть("Шапка");
	ОбластьСтрока = МакетОбработки.ПолучитьОбласть("Строка");
	ОбластьПодвал = МакетОбработки.ПолучитьОбласть("Подвал");
	
	//Запрос = Новый Запрос;
	//Запрос.Текст =
	//"ВЫБРАТЬ
	//|	ЗаказПоставщику.Ссылка КАК Ссылка,
	//|	ЗаказПоставщику.Номер КАК Номер,
	//|	ЗаказПоставщику.Дата КАК Дата,
	//|	ЗаказПоставщику.Организация КАК Организация,
	//|	ЗаказПоставщику.Контрагент КАК Контрагент,
	//|	ЗаказПоставщику.Товары.(
	//|		Ссылка КАК Ссылка,
	//|		НомерСтроки КАК НомерСтроки,
	//|		НоменклатураПартнера КАК НоменклатураПартнера,
	//|		Номенклатура КАК Номенклатура,
	//|		Характеристика КАК Характеристика,
	//|		Упаковка КАК Упаковка,
	//|		КоличествоУпаковок КАК КоличествоУпаковок,
	//|		Количество КАК Количество,
	//|		ДатаПоступления КАК ДатаПоступления,
	//|		ВидЦеныПоставщика КАК ВидЦеныПоставщика,
	//|		Цена КАК Цена,
	//|		Сумма КАК Сумма,
	//|		ПроцентРучнойСкидки КАК ПроцентРучнойСкидки,
	//|		СуммаРучнойСкидки КАК СуммаРучнойСкидки,
	//|		УдалитьСтавкаНДС КАК УдалитьСтавкаНДС,
	//|		СтавкаНДС КАК СтавкаНДС,
	//|		СуммаНДС КАК СуммаНДС,
	//|		СуммаСНДС КАК СуммаСНДС,
	//|		КодСтроки КАК КодСтроки,
	//|		Отменено КАК Отменено,
	//|		СтатьяРасходов КАК СтатьяРасходов,
	//|		АналитикаРасходов КАК АналитикаРасходов,
	//|		ПричинаОтмены КАК ПричинаОтмены,
	//|		Склад КАК Склад,
	//|		Назначение КАК Назначение,
	//|		Подразделение КАК Подразделение,
	//|		СписатьНаРасходы КАК СписатьНаРасходы,
	//|		ИдентификаторСтроки КАК ИдентификаторСтроки,
	//|		ДатаОтгрузки КАК ДатаОтгрузки
	//|	) КАК Товары,
	//|	ЗаказПоставщику.гф_ПродукцияВКоробах.(
	//|		Ссылка КАК Ссылка,
	//|		НомерСтроки КАК НомерСтроки,
	//|		ВариантКомплектации КАК ВариантКомплектации,
	//|		КоличествоКоробов КАК КоличествоКоробов,
	//|		IDКороба КАК IDКороба,
	//|		СтоимостьКороба КАК СтоимостьКороба,
	//|		НДС КАК НДС,
	//|		Сумма КАК Сумма
	//|	) КАК гф_ПродукцияВКоробах,
	//|	ЗаказПоставщику.СуммаДокумента КАК СуммаДокумента
	//|ИЗ
	//|	Документ.ЗаказПоставщику КАК ЗаказПоставщику
	//|ГДЕ
	//|	ЗаказПоставщику.Ссылка = &Ссылка";
	//Запрос.Параметры.Вставить("Ссылка",МассивДок[0].Ссылка);
	//Таб = Запрос.Выполнить().Выгрузить();
	
	// Заполнение области Шапка
	// Удаление нулей из номера документа
	НомерДок = Прав(МассивОбъект.Номер, 6);
	НомерБезНулей = НомерДок;
	Пока Найти(НомерБезНулей,"0") = 1 Цикл
		НомерБезНулей = Сред(НомерБезНулей,2); //удаляет лидирующие нули
	КонецЦикла;
	//
	ОбластьШапка.Параметры.НомерЗаказа = "Заказ поставщику № " + НомерБезНулей + " от " + Формат(МассивОбъект.Дата, "ДЛФ=ДД");
	ОбластьШапка.Параметры.Поставщик   = МассивОбъект.Организация.Наименование + ", ИНН " + МассивОбъект.Организация.ИНН + ", КПП " + МассивОбъект.Организация.КПП; 
	ОбластьШапка.Параметры.Покупатель  = МассивОбъект.Контрагент.Наименование + ", ИНН " + МассивОбъект.Контрагент.ИНН + ", КПП " + МассивОбъект.Контрагент.КПП;
	ТабличныйДокумент.Вывести(ОбластьШапка);
	//
	ТабличныйДокументКолонки = Новый ТабличныйДокумент;
	ТабличныйДокументЛево    = Новый ТабличныйДокумент;
	ТабличныйДокументЦентр   = Новый ТабличныйДокумент;
	ТабличныйДокументПраво   = Новый ТабличныйДокумент;
	ИтогоКоробов = 0;
	ИтогоПар     = 0;
	//Заполнение области Строка
	НомерСтроки = 1;
	Для Каждого СтрТов Из МассивОбъект.гф_ПродукцияВКоробах Цикл
		
		ОбластьЛево = МакетОбработки.ПолучитьОбласть("СтрокаЛево");
		ТабличныйДокументЛево.Вывести(ОбластьЛево);
		
		ОбластьОписаниеКартинка = МакетОбработки.ПолучитьОбласть("ОписаниеКартинка");
		ТабличныйДокументЦентр.Вывести(ОбластьОписаниеКартинка);
		
		ОбластьПраво = МакетОбработки.ПолучитьОбласть("СтрокаПраво");
		ТабличныйДокументПраво.Вывести(ОбластьПраво);
		
		Пары = "";
		Размер = "";
		
		Для Каждого Стр Из СтрТов.ВариантКомплектации.Товары Цикл
			
			Пары = Пары + Стр.Количество + "
			|";
			Размер = Размер + Стр.Характеристика.Наименование + "
			|";
			ОбластьЛево.Параметры.Номер                  = НомерСтроки;
			ОбластьПраво.Параметры.Пар                   = Стр.Номенклатура.ЕдиницаИзмерения.Наименование;
			
			Запрос = Новый Запрос;
			Запрос.Текст =
			"ВЫБРАТЬ
			|	Номенклатура.Ссылка КАК Ссылка,
			|	Номенклатура.ФайлКартинки КАК ФайлКартинки
			|ИЗ
			|	Справочник.Номенклатура КАК Номенклатура
			|ГДЕ
			|	Номенклатура.Ссылка = &Ссылка";
			Запрос.Параметры.Вставить("Ссылка",Стр.Номенклатура.Ссылка);
			ТабНоменклатура = Запрос.Выполнить().Выгрузить();
			
			ИтогоПар = ИтогоПар + Стр.Количество;
			
		КонецЦикла;
		
		Попытка
			УстановитьПривилегированныйРежим(Истина);
			КартинкаНоменклатуры = РаботаСФайлами.ДвоичныеДанныеФайла(ТабНоменклатура[0].ФайлКартинки);
			УстановитьПривилегированныйРежим(Ложь);
		Исключение
			КартинкаНоменклатуры = Неопределено;
		КонецПопытки;
		
		Если ЗначениеЗаполнено(КартинкаНоменклатуры) Тогда
			ОбластьКартинка = ОбластьОписаниеКартинка.Области.АдресКартинки;
			
			Если ТипЗнч(КартинкаНоменклатуры) = Тип("Картинка") Тогда
				ОбластьКартинка.Картинка = КартинкаНоменклатуры;
			ИначеЕсли ТипЗнч(КартинкаНоменклатуры) = Тип("ДвоичныеДанные") Тогда
				КартинкаКарточки = Новый Картинка(КартинкаНоменклатуры);
				
				ОбластьКартинка.Картинка = ?(КартинкаКарточки.Формат() = ФорматКартинки.НеизвестныйФормат,
				Неопределено,
				КартинкаКарточки);
			КонецЕсли;
			
		КонецЕсли;
		
		КолУпак = 0;
		Для Каждого СтрКомпл Из СтрТов.ВариантКомплектации.Товары Цикл
			
			КолУпак = КолУпак + СтрКомпл.Количество;
			
		КонецЦикла;
		
		ОбластьПраво.Параметры.Артикул               = СтрТов.ВариантКомплектации.Наименование;
		ОбластьПраво.Параметры.Товар                 = СтрТов.ВариантКомплектации.Владелец.НаименованиеПолное + " (" + КолУпак + " пар/кор)";
		//ОбластьПраво.Параметры.Цвет                  = ;
		ОбластьПраво.Параметры.ТорговаяМарка         = СтрТов.ВариантКомплектации.Владелец.Ссылка.Марка.Наименование;
		ОбластьПраво.Параметры.Размеры               = Размер;
		ОбластьПраво.Параметры.КоличествоПар         = Пары;
		ОбластьПраво.Параметры.Цена                  = СтрТов.СтоимостьКороба;
		ОбластьПраво.Параметры.Сумма                 = СтрТов.Сумма;
		
		
		НомерСтроки = НомерСтроки + 1;
		
		Запрос = Новый Запрос;
		Запрос.Текст =
		"ВЫБРАТЬ
		|	ДополнительныеСведения.Объект КАК Объект,
		|	ДополнительныеСведения.Свойство КАК Свойство,
		|	ДополнительныеСведения.Значение КАК Значение
		|ИЗ
		|	РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведения
		|ГДЕ
		|	ДополнительныеСведения.Объект = &Объект";
		Запрос.Параметры.Вставить("Объект",СтрТов.ВариантКомплектации.Владелец);
		Таб = Запрос.Выполнить().Выгрузить();
		
		Если Не Таб.Количество() = 0 Тогда
			Для Каждого СтрЦвет Из Таб Цикл
				Если СтрЦвет.Свойство.Наименование = "Color_Name" Тогда
					   ОбластьПраво.Параметры.Цвет = СтрЦвет.Значение;
					   Прервать;
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		
		ТабличныйДокумент.Вывести(ОбластьЛево);
		ТабличныйДокумент.Присоединить(ОбластьОписаниеКартинка);
		ТабличныйДокумент.Присоединить(ОбластьПраво);
		
	КонецЦикла;
	//
    
	ОбластьПодвал.Параметры.ИтогоКоличествоПар     = ИтогоПар;
	ОбластьПодвал.Параметры.ИтогоСумма             = МассивОбъект.СуммаДокумента;
	ОбластьПодвал.Параметры.НаименованийНаСумму = "Всего наименований " + НомерСтроки + " , на сумму " +МассивОбъект.СуммаДокумента + " руб.";
	ОбластьПодвал.Параметры.СуммаПрописью = ЧислоПрописью(МассивОбъект.СуммаДокумента, "Л=ru_RU", "рубль, рубля, рублей, м, копейка, копейки, копеек, ж, 2");
	//ОбластьПодвал.Параметры.Руководитель = ;
	//ОбластьПодвал.Параметры.Бухгалтер = ;
	
	ТабличныйДокумент.Вывести(ОбластьПодвал);
	
	КонецЦикла;
	
	Возврат ТабличныйДокумент;
	
КонецФункции	
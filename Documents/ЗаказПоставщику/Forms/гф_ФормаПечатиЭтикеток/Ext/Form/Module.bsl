﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	ДокСсылка = Параметры.ЗаказПоставщику;
	УпаковочныеЛистыДляПечати.Загрузить(ДокСсылка.гф_IDКоробов.Выгрузить());
	Для каждого Стр Из УпаковочныеЛистыДляПечати Цикл
		Стр.Пометка = Истина;
	КонецЦикла;
	
	Склад = ДокСсылка.Склад;
	
КонецПроцедуры

&НаСервере
Процедура ОрганизацияПриИзмененииНаСервере()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ОрганизацииКонтактнаяИнформация.Представление КАК Представление
		|ИЗ
		|	Справочник.Организации.КонтактнаяИнформация КАК ОрганизацииКонтактнаяИнформация
		|ГДЕ
		|	ОрганизацииКонтактнаяИнформация.Ссылка = &Ссылка
		|	И ОрганизацииКонтактнаяИнформация.Вид = &Вид";
	
	Запрос.УстановитьПараметр("Вид", ПредопределенноеЗначение("Справочник.ВидыКонтактнойИнформации.ЮрАдресОрганизации"));
	Запрос.УстановитьПараметр("Ссылка", Организация);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Выборка.Следующий();
    Адрес = Выборка.Представление;

КонецПроцедуры

&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)
	ОрганизацияПриИзмененииНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ВыборПроизводителяПриИзменении(Элемент)
	
	Если ВыборПроизводителя = "1" Тогда
		Элементы.Адрес.Доступность = Ложь;
		Элементы.Организация.Доступность = Ложь;
	Иначе
		Элементы.Адрес.Доступность = Истина;
		Элементы.Организация.Доступность = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	ЭтаФорма.Модифицированность = Ложь;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы
 
&НаКлиенте
Процедура УстановитьМетки(Команда)  
		
	Если Команда = ЭтотОбъект.Команды.ОтметитьВсе Тогда
		
		Пометка = Истина;
		
	ИначеЕсли Команда = ЭтотОбъект.Команды.СнятьВсеОтметки Тогда
		
		Пометка = Ложь;
		
	Иначе       
		
		Возврат;
		
	КонецЕсли;			
	
	Для Каждого СтрокаТаблицы Из УпаковочныеЛистыДляПечати Цикл
		
		СтрокаТаблицы.Пометка = Пометка;
		
	КонецЦикла;	
	
КонецПроцедуры

&НаКлиенте
Процедура ПечатьЭтикеткиНаКлиенте(ИмяКоманды)
	
	НастройкиСвойствПечати = НастройкиСвойствЭтикеток;
	
	Если Не ЗначениеЗаполнено(НастройкиСвойствПечати) Тогда 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не назначены настройки для печати свойств");
		Возврат;
	КонецЕсли;
	АдресРезультата = ПечатьЭтикетки(Неопределено);
	
	// vvv Галфинд \ Sakovich 07.11.2023
	Если Не ЭтоАдресВременногоХранилища(АдресРезультата) Тогда
		Возврат;
	КонецЕсли;
	// ^^^ Галфинд \ Sakovich 07.11.2023
	
	ТабДок = ПолучитьИзВременногоХранилища(АдресРезультата);
	Если ТабДок = Неопределено Тогда
		Возврат;
	КонецЕсли;
			
	Если ИмяКоманды.Имя = "ПечатьСПредПросмотром" Тогда
		// предварительный просмотр	
		ТабДок.Показать("Печать этикеток"); 
		Возврат;
		
	ИначеЕсли ИмяКоманды.Имя = "Печать" Тогда
		// напечатать с диалогом выбора принтера
		ТабДок.Вывод = ИспользованиеВывода.Разрешить;
		ТабДок.Напечатать(РежимИспользованияДиалогаПечати.Использовать);
		Возврат;
		
	Иначе 
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция НайтиШтрикходУпаковкиТоваровИУпаковочныйЛистПоNVE()
	
	ТаблицаОтмеченныхУЛ = УпаковочныеЛистыДляПечати.Выгрузить(Новый Структура("Пометка", Истина));
	МассивОтмеченныхУЛ = ТаблицаОтмеченныхУЛ.ВыгрузитьКолонку("IDКороба");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ШтрихкодыУпаковокТоваров.Ссылка КАК ШтрихКодУпаковки,
		|	УпаковочныйЛист.Ссылка КАК УпаковочныйЛист
		|ИЗ
		|	Документ.УпаковочныйЛист КАК УпаковочныйЛист
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
		|		ПО УпаковочныйЛист.гф_Агрегация = ШтрихкодыУпаковокТоваров.Ссылка
		|ГДЕ
		|	УпаковочныйЛист.Ссылка В(&МассивУЛ)
		|	И ШтрихкодыУпаковокТоваров.ТипУпаковки = ЗНАЧЕНИЕ(Перечисление.ТипыУпаковок.МультитоварнаяУпаковка)
		|";

	Запрос.УстановитьПараметр("МассивУЛ", МассивОтмеченныхУЛ);
	
	РезультатЗапроса = Запрос.Выполнить();
		
	Если РезультатЗапроса.Пустой() Тогда
		Возврат Неопределено;
	Иначе
		Возврат РезультатЗапроса.Выгрузить();
	КонецЕсли;
	
КонецФункции

&НаКлиенте
Процедура РаспечататьДокументыНаПринтер(ТабличныйДок)
	
	ТабличныеДокументы = Новый СписокЗначений();
	ТабличныеДокументы.Добавить(ТабличныйДок);
	УправлениеПечатьюКлиент.РаспечататьТабличныеДокументы(
	ТабличныеДокументы, Новый СписокЗначений, , 1); 
	
КонецПроцедуры

 &НаСервере
Функция ПечатьЭтикетки(МассивКМДляПечати = Неопределено)
	
	ТаблицаШтрихкодУпаковочныйЛист = НайтиШтрикходУпаковкиТоваровИУпаковочныйЛистПоNVE();
	
	// vvv Галфинд \ Sakovich 07.11.2023
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee78c2bb2ea7c9 (п.6)
	// Проверка отключена
	//ЕстьNVEСкладе = ПроверитьНаличиеNVEНаСкладе(ТаблицаШтрихкодУпаковочныйЛист.ВыгрузитьКолонку("ШтрихКодУпаковки"));
	//Если Не ЕстьNVEСкладе Тогда
	//	ОбщегоНазначения.СообщитьПользователю("На складе " + Склад + " не найдены NVE по УЛ из таблицы IDКоробов");
	//	Возврат Неопределено;
	//КонецЕсли;
	// ^^^ Галфинд \ Sakovich 07.11.2023
	
	ТД = Новый ТабличныйДокумент;
	ДокОбъект = ДокСсылка.ПолучитьОбъект();
	Макет = ДокОбъект.ПолучитьМакет("Этикетка_2"); // изм. Макет Галфинд_ДомнышеваКР_01_04_2024
	
	ПервыйЛист = Истина;
			
	Для каждого СтрокаШУл Из ТаблицаШтрихкодУпаковочныйЛист Цикл
		
		Если Не ПервыйЛист Тогда
			ТД.ВывестиГоризонтальныйРазделительСтраниц();
		Иначе
			ПервыйЛист = Ложь;
		КонецЕсли;
		тзТовары = ЗаполнитьТаблицуТоваров(СтрокаШУл);
		
		ПараметрыЗаголовка =  ПараметрыЗаголовкаПечатьNVE(тзТовары[0]);
		
		Если Не МассивКМДляПечати = Неопределено Тогда
			Для Каждого СтрокаТЧ Из тзТовары Цикл
				
				СтрокаТЧ.Пометка = Ложь;
				
				Если Не МассивКМДляПечати.Найти(СтрокаТЧ.КМ) = Неопределено Тогда
					СтрокаТЧ.Пометка = Истина;
				КонецЕсли;	
				
			КонецЦикла;
		КонецЕсли;
		
		ДеревоТовары = ПолучитьДеревоДанных(тзТовары);
				
		ГраницаМакета 		= 13;
		КоличествоСтрок 	= 2;
		КоличествоКолонок 	= 6;
		ЭтикетокНаЛисте 	= КоличествоСтрок * КоличествоКолонок;
		ИндексЭтикетки 		= 0;
		ВсегоНужноНапечататьЭтикеток = тзТовары.Итог("КоличествоЭтикеток");
					
		ПечатьЗаголовка(ТД, Макет, ПараметрыЗаголовка);
		
		ИндексСтроки = 1;
		ИндексКолонки = 1;
		
		ВывелиПодвал = Ложь;
				
		Для Каждого строка Из тзТовары Цикл
			
			Если Не Строка["Пометка"] Тогда
				Продолжить;
			КонецЕсли;		
			
			мНоменклатура = строка.Номенклатура;
			
			ОписаниеТовара = Строка(мНоменклатура) + " (" + строка.Артикул + ")";
			
			Нашли = ДеревоТовары.строки.Найти(мНоменклатура);
			Если Нашли = Неопределено Тогда
				Текст = "" + мНоменклатура + " не найдены свойства для печати этикетки!";
				ОбщегоНазначения.СообщитьПользователю(Текст);
				Продолжить;
			Иначе
				таб = Нашли.Строки;
			КонецЕсли;
			
			ОбластьОсновная = Макет.ПолучитьОбласть("ОбластьОсновная");
			ОбластьОсновная.Параметры.Размер = "" + Строка["Характеристика"];
			Этикетка = "";
			РисунокШтрихкод = ОбластьОсновная.Рисунки.Штрихкод;
			
			Если строка.КМ.Пустая() Тогда
				ОбластьОсновная.Рисунки.Удалить(РисунокШтрихкод);
			Иначе
				ОбластьОсновная.Рисунки.Удалить(ОбластьОсновная.Рисунки.eac);
				Штрихкод = строка["ПолныйКодМаркировки"];
				ШтрихКодНаПечать = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(строка.КМ, "ЗначениеШтрихкода");
				
				ТипКода = 24;
				Ширина = 220;
				Высота = 220;
				УголПоворота = 0;
				УровеньКоррекцииQR = 0;
				
				ПараметрыШтрихкода = ГенерацияШтрихкода.ПараметрыГенерацииШтрихкода();
				ПараметрыШтрихкода["Ширина"] = Ширина;
				ПараметрыШтрихкода["Высота"] = Высота;
				ПараметрыШтрихкода["ТипКода"] = ТипКода;
				ПараметрыШтрихКода["ОтображатьТекст"] = Истина;
				ПараметрыШтрихкода["РазмерШрифта"] = 10;
				ПараметрыШтрихкода["УголПоворота"] = УголПоворота;
				
				ПараметрыШтрихкода["Штрихкод"] = Штрихкод;
				ПараметрыШтрихкода["ПрозрачныйФон"] = Истина;
				ПараметрыШтрихкода["УровеньКоррекцииQR"] = УровеньКоррекцииQR;
				ПараметрыШтрихКода["ТипВходныхДанных"] = 1;
				СтруктураКартинки = ГенерацияШтрихкода.ИзображениеШтрихкода(ПараметрыШтрихкода);    		
				
				РисунокШтрихкод.Картинка = СтруктураКартинки.Картинка;
				РисунокШтрихкод.ГраницаСверху = Ложь;
				РисунокШтрихкод.ГраницаСлева = Ложь;
				РисунокШтрихкод.ГраницаСнизу = Ложь;
				РисунокШтрихкод.ГраницаСправа = Ложь;
				РисунокШтрихкод.Защита = Ложь;
				// ++ Галфинд_ДомнышеваКР_28_07_2023
				// в КМ могут присутствовать символы ")" и "(" в хвосте, по этому преобразование
				Если   Лев(ШтрихКодНаПечать, 1) = "("  Тогда
					НовоеЗначение = Сред(ШтрихКодНаПечать, 2, 2) + Сред(ШтрихКодНаПечать, 5, 14)
					+ Сред(ШтрихКодНаПечать, 20, 2) + Сред(ШтрихКодНаПечать, 23);
					ШтрихКодНаПечать = НовоеЗначение;
				КонецЕсли;
				//ШтрихКодНаПечать = СтрЗаменить(ШтрихКодНаПечать, "(", "");
				//ШтрихКодНаПечать = СтрЗаменить(ШтрихКодНаПечать, ")", "");
				// -- Галфинд_ДомнышеваКР_28_07_2023

				ОбластьОсновная.Параметры.КодМаркировки = ШтрихКодНаПечать;
				
			КонецЕсли;
			
			ЕстьОписание = Ложь;
			СтрокаОписание = Неопределено;
			ЗначениеОписание = Неопределено;
			
			ДатаИзготовления = ПолучитьДатуИзготовленияКМ(тзТовары, Строка); 
			Этикетка = ПолучитьДанныеЭтикетки(мНоменклатура, ДатаИзготовления, строка.Характеристика);
			ОбластьОсновная.Параметры.Этикетка = Этикетка;
			
			ВывелиПодвал = Ложь; 
			
			Для а = 1 По строка.КоличествоЭтикеток Цикл
				
				ИндексЭтикетки = ИндексЭтикетки + 1;
				
				Если ИндексКолонки = 1 Тогда
					ТД.Вывести(ОбластьОсновная);
				Иначе	
					ТД.Присоединить(ОбластьОсновная);
				КонецЕсли;
				
				Если ИндексКолонки = КоличествоКолонок Тогда
					ИндексКолонки = 1;
					ИндексСтроки = ИндексСтроки + 1;
				Иначе
					ИндексКолонки = ИндексКолонки + 1;
				КонецЕсли;
				
				Если ИндексЭтикетки = ЭтикетокНаЛисте или ИндексСтроки > КоличествоСтрок Тогда
					
					ПечатьПодвала(ТД, Макет, ПараметрыЗаголовка, ИндексСтроки - 1);
					ВывелиПодвал = Истина;
					
					Если Не (ИндексЭтикетки  = ВсегоНужноНапечататьЭтикеток) Тогда
						ТД.ВывестиГоризонтальныйРазделительСтраниц();
						ПечатьЗаголовка(ТД, Макет, ПараметрыЗаголовка);
					КонецЕсли;
					
					ИндексСтроки = 1;
					ИндексЭтикетки = 0;
				Иначе
					ВывелиПодвал = Ложь;
				КонецЕсли;
			КонецЦикла;
			
		КонецЦикла;
		
		Если НЕ ВывелиПодвал Тогда
			
			НадоСделатьВывод = Ложь;
			Если ИндексСтроки = 1 И ИндексЭтикетки < 6 Тогда
				
				ИндексЭтикетки = ИндексЭтикетки + 1;
				
				ОбластьОсновная = Макет.ПолучитьОбласть("ОбластьОсновная");
				ОбластьОсновная.Рисунки.Удалить(ОбластьОсновная.Рисунки.Штрихкод);
				ОбластьОсновная.Рисунки.Удалить(ОбластьОсновная.Рисунки.eac);
				
				Пока ИндексЭтикетки <= 6 Цикл
					ОбластьОсновная.Параметры.Размер 		= "";
					ОбластьОсновная.Параметры.Этикетка 		= "";
					ОбластьОсновная.Параметры.КодМаркировки = "";
					ТД.Присоединить(ОбластьОсновная);
					ИндексЭтикетки = ИндексЭтикетки + 1;
				КонецЦикла;
				
				ИндексСтроки = ИндексСтроки + 1;
				НадоСделатьВывод = Истина;
				
			ИначеЕсли ИндексСтроки = 2 И ИндексЭтикетки = 6 Тогда
				ИндексЭтикетки = ИндексЭтикетки + 1;
				НадоСделатьВывод = Истина;
			КонецЕсли;
			
			Если ИндексСтроки = 2 И ИндексЭтикетки < 12 Тогда
				
				ОбластьОсновная = Макет.ПолучитьОбласть("ОбластьОсновная");
				ОбластьОсновная.Рисунки.Удалить(ОбластьОсновная.Рисунки.Штрихкод);
				ОбластьОсновная.Рисунки.Удалить(ОбластьОсновная.Рисунки.eac);
				
				Если НадоСделатьВывод Тогда
					
					ОбластьОсновная.Параметры.Размер 		= "";
					ОбластьОсновная.Параметры.Этикетка 		= "";
					ОбластьОсновная.Параметры.КодМаркировки = "";
					ТД.Вывести(ОбластьОсновная);
					ИндексЭтикетки = ИндексЭтикетки + 1;
				КонецЕсли;
				
				Пока ИндексЭтикетки < 12 Цикл
					ОбластьОсновная.Параметры.Размер 		= "";
					ОбластьОсновная.Параметры.Этикетка 		= "";
					ОбластьОсновная.Параметры.КодМаркировки = "";
					ТД.Присоединить(ОбластьОсновная);
					ИндексЭтикетки = ИндексЭтикетки + 1;
				КонецЦикла;
			КонецЕсли;
			
			ПечатьПодвала(ТД, Макет, ПараметрыЗаголовка);
			ВывелиПодвал = Истина;
		КонецЕсли;	
	КонецЦикла;
	
	УстановитьПараметрыТабличногоДокумента(ТД);
						
	АдресРезультата = ПоместитьВоВременноеХранилище(ТД, Новый УникальныйИдентификатор);

	Возврат АдресРезультата;
	
КонецФункции

&НаСервере
Функция ПараметрыЗаголовкаПечатьNVE(СтрТЗ)
	ПараметрыЗаголовка = Новый Структура("NVE, АртикулУпаковки",
	СтрТЗ["NVE"], СтрТЗ["АртикулУпаковки"]);
	Возврат ПараметрыЗаголовка;
КонецФункции 

&НаСервере
Процедура ПечатьЗаголовка(ТД, Макет, ПараметрыЗаголовка)
	Область = Макет.ПолучитьОбласть("НомерСерии");
	Область.Параметры.НомерСерии = ПараметрыЗаголовка["NVE"];
	Область.Параметры.Артикул = ПараметрыЗаголовка["АртикулУпаковки"];
	
	// ++ Галфинд_ДомнышеваКР_01_04_2024
	// изменен макет, рисунок штрихкода перенесен в подвал
	//ПараметрыШтрихкода = ГенерацияШтрихкода.ПараметрыГенерацииШтрихкода();
	//ПараметрыШтрихкода.ТипКода = 99;
	//ПараметрыШтрихкода.Штрихкод = ПараметрыЗаголовка["NVE"];
	//ПараметрыШтрихкода.Ширина = 350;
	//ПараметрыШтрихкода.Высота = 150;
	//ПараметрыШтрихкода.ПрозрачныйФон = Истина;
	//ПараметрыШтрихкода.ОтображатьТекст = Ложь;
	//СтруктураКартинки = ГенерацияШтрихкода.ИзображениеШтрихкода(ПараметрыШтрихкода);
	//Область.Рисунки.штрих_серии_подвал.Картинка = СтруктураКартинки.Картинка;
	// -- Галфинд_ДомнышеваКР_01_04_2024
	
	ТД.Вывести(Область);
КонецПроцедуры

&НаСервере
Процедура ПечатьПодвала(ТД, Макет, ПараметрыЗаголовка, ЧислоЛинийQR = 2)
	ПустаяСтрока 	= Макет.ПолучитьОбласть("ПустаяСтрока");
	ТестоваяСтрока 	= Макет.ПолучитьОбласть("ТестоваяСтрока");
	
	Область = Макет.ПолучитьОбласть("НомерСерииПодвал");
	Область.Параметры.НомерСерии 				= ПараметрыЗаголовка["NVE"];
	// ++ Галфинд_ДомнышеваКР_01_04_2024
	// изменен макет, рисунок штрихкода перенесен в подвал
	Область.Параметры.ПоследниеПятьЦифрСерии 	= Прав(ПараметрыЗаголовка["NVE"], 5);
	Область.Параметры.Артикул 					= ПараметрыЗаголовка["АртикулУпаковки"];
	
	ПараметрыШтрихкода = ГенерацияШтрихкода.ПараметрыГенерацииШтрихкода();
	ПараметрыШтрихкода.ТипКода = 2;
	ПараметрыШтрихкода.Штрихкод = ПараметрыЗаголовка["NVE"];
	ПараметрыШтрихкода.Ширина = 350;
	ПараметрыШтрихкода.Высота = 150;
	ПараметрыШтрихкода.ПрозрачныйФон = Истина;
	ПараметрыШтрихкода.ОтображатьТекст = Ложь;
	СтруктураКартинки = ГенерацияШтрихкода.ИзображениеШтрихкода(ПараметрыШтрихкода);
	Область.Рисунки.штрих_серии_подвал.Картинка = СтруктураКартинки.Картинка;
	// -- Галфинд_ДомнышеваКР_01_04_2024

	//Область.Параметры.КодКонтрагентаИзЗаказа 			= ПараметрыЗаголовка["КодКлиента"];
	//Область.Параметры.НаименованиеКонтрагентаИзЗаказа 	= ПараметрыЗаголовка["Клиент"];
	Если ЧислоЛинийQR = 1 Тогда
		КолвоПустыхСтрок = 0;
		Пока ТД.ВысотаТаблицы % 37 <> 0 Цикл
			КолвоПустыхСтрок = КолвоПустыхСтрок + 1;
			ТД.Вывести(ПустаяСтрока);
		КонецЦикла;
	Иначе
		КолвоПустыхСтрок = 0;
		Пока ТД.ВысотаТаблицы % 40 <> 0 Цикл
			КолвоПустыхСтрок = КолвоПустыхСтрок + 1;
			ТД.Вывести(ПустаяСтрока);
		КонецЦикла;
	КонецЕсли;
	
	ТД.Вывести(Область);
	
КонецПроцедуры

&НаСервере
Функция ПолучитьДеревоДанных(ТаблицаТоваров)
	
	Запрос = Новый Запрос("ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Т.Номенклатура КАК Номенклатура
	|ПОМЕСТИТЬ Товары
	|ИЗ
	|	&Товары КАК Т
	|ГДЕ
	|	Т.Пометка
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	С.Ссылка КАК Объект,
	|	С.Свойство КАК Свойство,
	|	С.Значение КАК Значение
	|ПОМЕСТИТЬ Свойства
	|ИЗ
	|	Справочник.Номенклатура.ДополнительныеРеквизиты КАК С
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Товары КАК Товары
	|		ПО С.Ссылка = Товары.Номенклатура
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	Товары.Номенклатура,
	|	ДополнительныеСведения.Свойство,
	|	ДополнительныеСведения.Значение
	|ИЗ
	|	РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведения
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Товары КАК Товары
	|		ПО (Товары.Номенклатура = ДополнительныеСведения.Объект)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Объект
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Товары.Номенклатура КАК Номенклатура,
	|	Свойства.Свойство КАК Свойство,
	|	Свойства.Значение КАК Значение
	|ИЗ
	|	Товары КАК Товары
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Свойства КАК Свойства
	|		ПО Товары.Номенклатура = Свойства.Объект
	|
	|УПОРЯДОЧИТЬ ПО
	|	Номенклатура,
	|	Свойство
	|ИТОГИ ПО
	|	Номенклатура");
	
	Запрос.УстановитьПараметр("Товары", ТаблицаТоваров);
	
	Возврат Запрос.Выполнить().Выгрузить(ОбходРезультатаЗапроса.ПоГруппировкам);
	
КонецФункции

&НаСервере
Функция ПолучитьДанныеЭтикетки(Номенклатура, ДатаИзготовления, Характеристика)
	
	ПустоеСвойствоЭтикеткиСтрокой = "";
	
	Запрос = Новый Запрос("ВЫБРАТЬ
		|	ВЫБОР
		|		КОГДА ТИПЗНАЧЕНИЯ(вз.Реквизит) = ТИП(СТРОКА)
		|			ТОГДА ВЫРАЗИТЬ(вз.Реквизит КАК СТРОКА(300))
		|		ИНАЧЕ вз.Реквизит
		|	КОНЕЦ КАК РеквизитСтрока,
		|	вз.ТипДопСведения КАК ТипДопСведения,
		|	вз.ПорядокПоТипуДопСведения КАК ПорядокПоТипуДопСведения,
		|	вз.Порядок КАК Порядок,
		|	ВЫРАЗИТЬ(ДополнительныеСведения.Значение КАК СТРОКА(300)) КАК ЗначениеСвойства
		|ПОМЕСТИТЬ БЕЗПЕРЕВОДА
		|ИЗ
		|	(ВЫБРАТЬ
		|		гф_НастройкиПечатиСвойствЭтикеток.Ссылка КАК Ссылка,
		|		гф_НастройкиПечатиСвойствЭтикетокРеквизиты.Реквизит КАК Реквизит,
		|		""Реквизит"" КАК ТипДопСведения,
		|		1 КАК ПорядокПоТипуДопСведения,
		|		гф_НастройкиПечатиСвойствЭтикетокРеквизиты.Порядок КАК Порядок
		|	ИЗ
		|		Справочник.гф_НастройкиПечатиСвойствЭтикеток КАК гф_НастройкиПечатиСвойствЭтикеток
		|			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.гф_НастройкиПечатиСвойствЭтикеток.Реквизиты КАК гф_НастройкиПечатиСвойствЭтикетокРеквизиты
		|			ПО гф_НастройкиПечатиСвойствЭтикеток.Ссылка = гф_НастройкиПечатиСвойствЭтикетокРеквизиты.Ссылка
		|	ГДЕ
		|		гф_НастройкиПечатиСвойствЭтикеток.Ссылка = &Ссылка
		|	
		|	ОБЪЕДИНИТЬ ВСЕ
		|	
		|	ВЫБРАТЬ
		|		гф_НастройкиПечатиСвойствЭтикеток.Ссылка,
		|		гф_НастройкиПечатиСвойствЭтикетокДополнительныеСведения.Свойство,
		|		""Свойство"",
		|		2,
		|		гф_НастройкиПечатиСвойствЭтикетокДополнительныеСведения.Порядок
		|	ИЗ
		|		Справочник.гф_НастройкиПечатиСвойствЭтикеток КАК гф_НастройкиПечатиСвойствЭтикеток
		|			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.гф_НастройкиПечатиСвойствЭтикеток.ДополнительныеСведения КАК гф_НастройкиПечатиСвойствЭтикетокДополнительныеСведения
		|			ПО гф_НастройкиПечатиСвойствЭтикеток.Ссылка = гф_НастройкиПечатиСвойствЭтикетокДополнительныеСведения.Ссылка
		|	ГДЕ
		|		гф_НастройкиПечатиСвойствЭтикеток.Ссылка = &Ссылка) КАК вз
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ДополнительныеСведения КАК ДополнительныеСведения
		|		ПО (ДополнительныеСведения.Объект = &Ном)
		|			И вз.Реквизит = ДополнительныеСведения.Свойство
		|ГДЕ
		|	вз.Реквизит ЕСТЬ НЕ NULL 
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	БЕЗПЕРЕВОДА.РеквизитСтрока КАК РеквизитИлиСвойство,
		|	БЕЗПЕРЕВОДА.ТипДопСведения КАК ТипДопСведения,
		|	БЕЗПЕРЕВОДА.ПорядокПоТипуДопСведения КАК ПорядокПоТипуДопСведения,
		|	БЕЗПЕРЕВОДА.Порядок КАК Порядок,
		|	БЕЗПЕРЕВОДА.ЗначениеСвойства КАК ЗначениеСвойства,
		|	гф_ПереводЗначенийРеквизитовИСвойств.Значение КАК НаименованиеРеквизита
		|ПОМЕСТИТЬ ПереводНаименований
		|ИЗ
		|	БЕЗПЕРЕВОДА КАК БЕЗПЕРЕВОДА
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.гф_ПереводЗначенийРеквизитовИСвойств КАК гф_ПереводЗначенийРеквизитовИСвойств
		|		ПО (гф_ПереводЗначенийРеквизитовИСвойств.Объект = БЕЗПЕРЕВОДА.РеквизитСтрока)
		|			И (гф_ПереводЗначенийРеквизитовИСвойств.Язык = &Этикетки)
		|ГДЕ
		|	БЕЗПЕРЕВОДА.ТипДопСведения = ""Свойство""
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	БЕЗПЕРЕВОДА.РеквизитСтрока,
		|	БЕЗПЕРЕВОДА.ТипДопСведения,
		|	БЕЗПЕРЕВОДА.ПорядокПоТипуДопСведения,
		|	БЕЗПЕРЕВОДА.Порядок,
		|	БЕЗПЕРЕВОДА.ЗначениеСвойства,
		|	""""
		|ИЗ
		|	БЕЗПЕРЕВОДА КАК БЕЗПЕРЕВОДА
		|ГДЕ
		|	БЕЗПЕРЕВОДА.ТипДопСведения = ""Реквизит""
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ПереводНаименований.РеквизитИлиСвойство КАК РеквизитИлиСвойство,
		|	ПереводНаименований.ТипДопСведения КАК ТипДопСведения,
		|	ПереводНаименований.ПорядокПоТипуДопСведения КАК ПорядокПоТипуДопСведения,
		|	ПереводНаименований.Порядок КАК Порядок,
		|	ПереводНаименований.ЗначениеСвойства КАК ЗначениеСвойства,
		|	ВЫРАЗИТЬ(ПереводНаименований.НаименованиеРеквизита КАК СТРОКА(300)) КАК НаименованиеРеквизита,
		|	ВЫРАЗИТЬ(гф_ПереводЗначенийРеквизитовИСвойств.Значение КАК СТРОКА(300)) КАК Значение
		|ПОМЕСТИТЬ ИТОГО
		|ИЗ
		|	ПереводНаименований КАК ПереводНаименований
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.гф_ПереводЗначенийРеквизитовИСвойств КАК гф_ПереводЗначенийРеквизитовИСвойств
		|		ПО (гф_ПереводЗначенийРеквизитовИСвойств.Объект = ПереводНаименований.ЗначениеСвойства)
		|			И (гф_ПереводЗначенийРеквизитовИСвойств.Язык = &НацКаталог)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВЫБОР
		|		КОГДА ИТОГО.НаименованиеРеквизита <> """"
		|			ТОГДА ИТОГО.НаименованиеРеквизита
		|		ИНАЧЕ ИТОГО.РеквизитИлиСвойство
		|	КОНЕЦ КАК РеквизитИлиСвойство,
		|	ИТОГО.ТипДопСведения КАК ТипДопСведения,
		|	ИТОГО.ПорядокПоТипуДопСведения КАК ПорядокПоТипуДопСведения,
		|	ИТОГО.Порядок КАК Порядок,
		|	ВЫБОР
		|		КОГДА ИТОГО.Значение <> """"
		|			ТОГДА ИТОГО.Значение
		|		ИНАЧЕ ИТОГО.ЗначениеСвойства
		|	КОНЕЦ КАК ЗначениеСвойства
		|ИЗ
		|	ИТОГО КАК ИТОГО
		|
		|УПОРЯДОЧИТЬ ПО
		|	Порядок,
		|	ПорядокПоТипуДопСведения");
	
	Запрос.УстановитьПараметр("Ссылка", НастройкиСвойствЭтикеток.Ссылка);
	Запрос.УстановитьПараметр("Ном", Номенклатура);
	Запрос.УстановитьПараметр("НацКаталог", Справочники.гф_ВидыЯзыков.НацКаталог);
	Запрос.УстановитьПараметр("Этикетки", Справочники.гф_ВидыЯзыков.Этикетки);

	Результат = Запрос.Выполнить();
	
	Если Результат.Пустой() Тогда
		Возврат ПустоеСвойствоЭтикеткиСтрокой;
	КонецЕсли;
	
	ТипАдреса = ПредопределенноеЗначение("Справочник.ВидыКонтактнойИнформации.ЮрАдресКонтрагента");

	тз = Результат.Выгрузить();
	мСвойств = Новый Массив;
	Для каждого стрТЗ Из тз Цикл
		Если стрТЗ["ТипДопСведения"] = "Реквизит" Тогда 
			Если стрТЗ["РеквизитИлиСвойство"] = Null Тогда
				Продолжить;	
			Иначе
				Если стрТЗ["РеквизитИлиСвойство"] = "Производитель (импортер)" Тогда
					Реквизит = Метаданные.Справочники.Номенклатура.Реквизиты.ПроизводительИмпортерКонтрагент;
                Иначе
					Реквизит = ОпределитьРеквизит(стрТЗ["РеквизитИлиСвойство"]);
				КонецЕсли;
				стрТЗ["ЗначениеСвойства"] = Строка(Номенклатура[Реквизит.Имя]);
				Перевод = ПереводРеквизита(стрТЗ["РеквизитИлиСвойство"]);
				Если ЗначениеЗаполнено(Перевод) Тогда
					стрТЗ["РеквизитИлиСвойство"] = Перевод;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		ЗначениеСвойства = ?(ЗначениеЗаполнено(стрТЗ["ЗначениеСвойства"]), стрТЗ["ЗначениеСвойства"], "");
		
		Если СтрНачинаетсяС(стрТЗ["РеквизитИлиСвойство"], "Артикул") Тогда
			мСвойств.Добавить("" + стрТЗ["РеквизитИлиСвойство"]	+ ": " + ЗначениеСвойства + "/" + Характеристика);	
		ИначеЕсли СтрНачинаетсяС(стрТЗ["РеквизитИлиСвойство"], "Производитель")
			ИЛИ СтрНачинаетсяС(стрТЗ["РеквизитИлиСвойство"], "Импортер") Тогда
			
			Если ВыборПроизводителя = "0" Тогда 
				
				мСвойств.Добавить("" + "Производитель" + ": " + Организация);
				мСвойств.Добавить("" + "Адрес" + ": " + Адрес);  
				мСвойств.Добавить("" + "Продавец" + ": " + Организация);
				мСвойств.Добавить("" + "Адрес" + ": " + Адрес);
				
			Иначе
				мСвойств.Добавить("" + "Производитель" + ": " + ЗначениеСвойства);
				ЗначениеАдреса = ПолучитьАдрес(Номенклатура[Реквизит.Имя], ТипАдреса);
				мСвойств.Добавить("" + "Адрес" + ": " + ЗначениеАдреса);
				
				мСвойств.Добавить("" + "Продавец" + ": " + ЗначениеСвойства);
				мСвойств.Добавить("" + "Адрес" + ": " + ЗначениеАдреса);
	
			КонецЕсли; 
		
		Иначе	
			мСвойств.Добавить("" + стрТЗ["РеквизитИлиСвойство"]	+ ": " + ЗначениеСвойства); 
		КонецЕсли;
		
	КонецЦикла;
	
	мСвойств.Добавить("" + "Дата Изготовления" + ": " + ДатаИзготовления);	            
	ЗапомнилиСтроку = Неопределено;
	Если ВыборПроизводителя = "0" Тогда
		Для Каждого Стр Из мСвойств Цикл
			Если СтрНачинаетсяС(Стр, "" + "Производитель") Тогда
				ЗапомнилиСтроку = Стр;
			КонецЕсли;
		КонецЦикла;
		Если ЗапомнилиСтроку = Неопределено Тогда
			мСвойств.Добавить("" + "Производитель" + ": " + Организация);
			мСвойств.Добавить("" + "Адрес" + ": " + Адрес);
			мСвойств.Добавить("" + "Продавец" + ": " + Организация);
			мСвойств.Добавить("" + "Адрес" + ": " + Адрес);
		КонецЕсли;
	КонецЕсли;

	СвойствоЭтикеткиСтрокой = СтрСоединить(мСвойств, ", ");
	Возврат СвойствоЭтикеткиСтрокой + Символы.ПС; 
	
КонецФункции

&НаСервере
Функция ПолучитьДатуИзготовленияКМ(тзТовары, Строка)
	
	// Получение дат изготовления КМ
	ЗапросКМ = Новый Запрос;
	ЗапросКМ.Текст = 
	"ВЫБРАТЬ
	|	ТЧ.Номенклатура КАК Номенклатура,
	|	ТЧ.Характеристика КАК Характеристика,
	|	ТЧ.КМ КАК КМ
	|ПОМЕСТИТЬ ВТ_ТЧ
	|ИЗ
	|	&ТЧ КАК ТЧ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ТЧ.Номенклатура КАК Номенклатура,
	|	ВТ_ТЧ.Характеристика КАК Характеристика,
	|	ВТ_ТЧ.КМ КАК КМ,
	|	ЕСТЬNULL(ПулКодовМаркировкиСУЗ.ДатаЭмиссииУниверсальная, ДАТАВРЕМЯ(1, 1, 1)) КАК ДатаИзготовленияКМ
	|ИЗ
	|	ВТ_ТЧ КАК ВТ_ТЧ
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
	|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПулКодовМаркировкиСУЗ КАК ПулКодовМаркировкиСУЗ
	|			ПО (ПулКодовМаркировкиСУЗ.КодМаркировки = ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода)
	|		ПО ВТ_ТЧ.КМ = ШтрихкодыУпаковокТоваров.Ссылка";
	ЗапросКМ.УстановитьПараметр("ТЧ", тзТовары);
	
	ТаблицаСДатами = ЗапросКМ.Выполнить().Выгрузить();
	ТаблицаСДатами.Индексы.Добавить("Номенклатура, Характеристика, КМ");
	
	СтруктураПоискаДаты = Новый Структура("Номенклатура, Характеристика, КМ");
	
        СтруктураПоискаДаты.Номенклатура = Строка.Номенклатура;
		СтруктураПоискаДаты.Характеристика = Строка.Характеристика;
		СтруктураПоискаДаты.КМ = Строка.КМ;
		СтрокаСДатой = ТаблицаСДатами.НайтиСтроки(СтруктураПоискаДаты);
		Если СтрокаСДатой.Количество() > 0 Тогда
			ДатаИзготовления = Формат(СтрокаСДатой[0].ДатаИзготовленияКМ, "ДФ = дд.ММ.гггг");
		Иначе
			ДатаИзготовления = Дата(1,1,1);
		КонецЕсли;
   Возврат ДатаИзготовления;
	
КонецФункции// } #wortmann

// #wortmann { 
// Получает перевод значения реквизита из РС гф_ПереводЗначенийРеквизитовИСвойств 
// Галфинд_Домнышева 2023/04/24
&НаСервере
Функция ПереводРеквизита(Реквизит)  
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	гф_ПереводЗначенийРеквизитовИСвойств.Значение КАК Наименование
		|ИЗ
		|	РегистрСведений.гф_ПереводЗначенийРеквизитовИСвойств КАК гф_ПереводЗначенийРеквизитовИСвойств
		|ГДЕ
		|	гф_ПереводЗначенийРеквизитовИСвойств.Объект = &Реквизит
		|	И гф_ПереводЗначенийРеквизитовИСвойств.Язык = &Этикетки";
	
	Запрос.УстановитьПараметр("Реквизит", Реквизит);
	Запрос.УстановитьПараметр("Этикетки",  Справочники.гф_ВидыЯзыков.НайтиПоНаименованию("Этикетки"));
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка.Следующий();
		Возврат Выборка.Наименование;
	Иначе
		Возврат Неопределено;
	КонецЕсли;
	
КонецФункции// } #wortmann

// #wortmann { 
// Получает Реквизит по Синониму 
// Галфинд_Домнышева 2023/04/24
&НаСервере
Функция ОпределитьРеквизит(Синоним) 
	
	Для каждого Реквизит Из Метаданные.Справочники.Номенклатура.Реквизиты Цикл
		Если Реквизит.Синоним = Синоним Тогда
			Возврат Реквизит;
		КонецЕсли;
	КонецЦикла;
	
КонецФункции// } #wortmann

// #wortmann { 
// Получает соответствующего вида адрес для Контрагента  
// Галфинд_Домнышева 2023/04/24
&НаСервере
Функция ПолучитьАдрес(Получатель, ВидАдреса) 
	
	Если ТипЗнч(Получатель) = Тип("СправочникСсылка.Контрагенты") Тогда
		ИскомыйКонтрагент = Получатель;
	Иначе
		Возврат "";
	КонецЕсли;	
		
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	КонтрагентыКонтактнаяИнформация.Представление КАК Адрес
		|ИЗ
		|	Справочник.Контрагенты.КонтактнаяИнформация КАК КонтрагентыКонтактнаяИнформация
		|ГДЕ
		|	КонтрагентыКонтактнаяИнформация.Вид = &Вид
		|	И КонтрагентыКонтактнаяИнформация.Тип = &Тип
		|	И КонтрагентыКонтактнаяИнформация.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Вид", ВидАдреса);
	Запрос.УстановитьПараметр("Ссылка", ИскомыйКонтрагент);
	Запрос.УстановитьПараметр("Тип", Перечисления.ТипыКонтактнойИнформации.Адрес);
		
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Если Не РезультатЗапроса.Пустой() Тогда
		Выборка.Следующий();
		Возврат Выборка.Адрес;
	Иначе
		Возврат "";
	КонецЕсли;
	
КонецФункции// } #wortmann

// #wortmann { 
// Получает Наличие штрихкодов на складе 
// Галфинд_Домнышева 2023/06/15
&НаСервере
Функция ПроверитьНаличиеNVEНаСкладе(КМ)
	
	Запрос = Новый Запрос("
	|ВЫБРАТЬ
	|	ОстаткиКМ.КМ КАК КМ,
	|	ОстаткиКМ.Склад КАК Склад,
	|	ОстаткиКМ.КоличествоОстаток КАК КоличествоОстаток
	|ИЗ
	|	РегистрНакопления.гф_ДвижениеКодовМаркировкиОрганизации.Остатки(
	|			,
	|			Склад  = &Склад
	|				И КМ В (&КМ)) КАК ОстаткиКМ
	|ГДЕ
	|	ОстаткиКМ.КоличествоОстаток >= 1");
	Запрос.УстановитьПараметр("Склад", Склад);
	Запрос.УстановитьПараметр("КМ", КМ);
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат Ложь;
	Иначе
		Возврат Истина;
	КонецЕсли;
	
КонецФункции

// Параметры - Структура - содержит ссылку на УпаковочныйЛист и ссылку на агрегат ШтрихкодыУпаковокТоваров
//					* ШтрихКодУпаковки - СправочникСсылка.ШтрихкодыУпаковокТоваров
//					* УпаковочныйЛист - ДокументСсылка.УпаковочныйЛист
&НаСервере
Функция ЗаполнитьТаблицуТоваров(СтруктураШК_УЛ)
	
	ШтрихКод = СтруктураШК_УЛ["ШтрихКодУпаковки"];
	УпаковочныйЛист = СтруктураШК_УЛ["УпаковочныйЛист"];
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	УпаковочныйЛист.Ссылка КАК УпаковочныйЛист,
	|	УпаковочныйЛист.гф_Комплектация КАК АртикулУпаковки,
	|	УпаковочныйЛист.Код КАК КодУпЛиста,
	|	УпаковочныйЛист.гф_Агрегация КАК Агрегат
	|ПОМЕСТИТЬ УпЛист
	|ИЗ
	|	Документ.УпаковочныйЛист КАК УпаковочныйЛист
	|ГДЕ
	|	УпаковочныйЛист.Ссылка = &УпаковочныйЛист
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТчВложенныеШтрихкоды.Ссылка КАК Агрегат,
	|	СпрНоменклатура.Артикул КАК Артикул,
	|	СпрШтрихкоды.Номенклатура КАК Номенклатура,
	|	СпрШтрихкоды.Характеристика КАК Характеристика,
	// #wortmann { 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee224d0352ee32 
	// Галфинд_Домнышева 2023/07/19
	|	СпрШтрихкоды.гф_ПолныйКодМаркировки КАК ПолныйКМ,
	// } #wortmann
	|	1 КАК КоличествоБазЕдиниц,
	|	СпрНоменклатура.ЕдиницаИзмерения КАК ЕдИзмБазовая,
	|	СпрНоменклатура.СтранаПроисхождения КАК СтранаПроисхождения,
	|	СпрШтрихкоды.Ссылка КАК КМ
	|ПОМЕСТИТЬ Штрихкоды
	|ИЗ
	|	Справочник.ШтрихкодыУпаковокТоваров.ВложенныеШтрихкоды КАК ТчВложенныеШтрихкоды
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ШтрихкодыУпаковокТоваров КАК СпрШтрихкоды
	|			ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК СпрНоменклатура
	|			ПО (СпрНоменклатура.Ссылка = СпрШтрихкоды.Номенклатура)
	|		ПО ТчВложенныеШтрихкоды.Штрихкод = СпрШтрихкоды.Ссылка
	|ГДЕ
	|	ТчВложенныеШтрихкоды.Ссылка = &Агрегат
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ИСТИНА КАК Пометка,
	|	УпЛист.АртикулУпаковки КАК АртикулУпаковки,
	|	Штрихкоды.Артикул КАК Артикул,
	|	Штрихкоды.Номенклатура КАК Номенклатура,
	|	Штрихкоды.Характеристика КАК Характеристика,
	|	Штрихкоды.КоличествоБазЕдиниц КАК КоличествоБазЕдиниц,
	|	Штрихкоды.ЕдИзмБазовая КАК ЕдИзмБазовая,
	|	Штрихкоды.Агрегат КАК NVE,
	|	Штрихкоды.СтранаПроисхождения КАК СтранаПроисхождения,
	|	Штрихкоды.КМ КАК КМ,
	|	1 КАК КоличествоЭтикеток,
	|	ВЫБОР
	// #wortmann { 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee224d0352ee32 
	// Галфинд_Домнышева 2023/07/19
	|		КОГДА Штрихкоды.ПолныйКМ <> """" 
	|			ТОГДА Штрихкоды.ПолныйКМ
	|		ИНАЧЕ ВЫБОР
	// } #wortmann
	|		КОГДА ПулКодов.ПолныйКодМаркировки ЕСТЬ НЕ NULL 
	|			ТОГДА ПулКодов.ПолныйКодМаркировки
	|		ИНАЧЕ Штрихкоды.КМ.ЗначениеШтрихкода
	// #wortmann { 
	// e1cib/data/Задача.ЗадачаИсполнителя?ref=8eabb083fed1320811ee224d0352ee32 
	// Галфинд_Домнышева 2023/07/19
	|		КОНЕЦ
	// } #wortmann
	|	КОНЕЦ КАК ПолныйКодМаркировки
	|ИЗ
	|	Штрихкоды КАК Штрихкоды
	|		ЛЕВОЕ СОЕДИНЕНИЕ УпЛист КАК УпЛист
	|		ПО Штрихкоды.Агрегат = УпЛист.Агрегат
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПулКодовМаркировкиСУЗ КАК ПулКодов
	|		ПО Штрихкоды.КМ.ЗначениеШтрихкода = ПулКодов.КодМаркировки
	|
	|УПОРЯДОЧИТЬ ПО
	|	Штрихкоды.Агрегат,
	|	Штрихкоды.Характеристика.Наименование";
	
	Запрос.УстановитьПараметр("УпаковочныйЛист", УпаковочныйЛист);
	Запрос.УстановитьПараметр("Агрегат", ШтрихКод);
	Результат = Запрос.Выполнить();
	Таблица = Результат.Выгрузить();
	Возврат Таблица;
	//Объект.Товары.Загрузить(Таблица);
КонецФункции

&НаСервереБезКонтекста
Процедура УстановитьПараметрыТабличногоДокумента(ТД)

	ТД.РазмерСтраницы = "A4";
	ТД.АвтоМасштаб = Ложь;
	ТД.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
	ТД.ПолеСверху = 10; // Галфинд_ДомнышеваКР_02_05_2023 - изменено так как не влезало на лист
	ТД.ПолеСнизу = 10; // Галфинд_ДомнышеваКР_02_05_2023 - изменено так как не влезало на лист
	ТД.ПолеСлева = 21; 
	ТД.ПолеСправа = 20;
	ТД.КоличествоЭкземпляров = 1;
	ТД.Защита = Истина;
	
	ТД.ТолькоПросмотр = Истина;
	ТД.ОтображатьСетку = Ложь;
	ТД.ОтображатьЗаголовки = Ложь;
	ТД.КлючПараметровПечати = "ПЕЧАТЬ_ЭТИКЕТОК_РМК";

КонецПроцедуры

#КонецОбласти
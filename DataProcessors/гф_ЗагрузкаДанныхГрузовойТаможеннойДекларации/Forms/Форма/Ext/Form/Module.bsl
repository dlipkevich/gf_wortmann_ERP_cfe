﻿&НаСервере
Функция ЭтоТаблицаЗначений(ТекЗначение)
	
	Возврат ТипЗнч(ТекЗначение) = Тип("ТаблицаЗначений");
	
КонецФункции

&НаСервере
Функция ЭтоЧисло(ТекЗначение)
	
	Возврат ТипЗнч(ТекЗначение) = Тип("Число");
	
КонецФункции

&НаСервере
Функция ЭтоСоответствие(ТекЗначение)
	
	Возврат ТипЗнч(ТекЗначение) = Тип("Соответствие");
	
КонецФункции

&НаСервере
Функция ЭтоСтрокаТаблицыЗначений(ТекЗначение)
	
	Возврат ТипЗнч(ТекЗначение) = Тип("СтрокаТаблицыЗначений");
	
КонецФункции

&НаСервере
Процедура СохранитьНастройкиНаСервере()
	
	СтруктураНастроек = Новый Структура;
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	
	Для Каждого Реквизит Из ОбработкаОбъект.Метаданные().Реквизиты Цикл
		СтруктураНастроек.Вставить(Реквизит.Имя, Объект[Реквизит.Имя]);		
	КонецЦикла;
	
	ИмяОбработки = СокрЛП(ОбработкаОбъект.Метаданные().Имя);
	
	ХранилищеОбщихНастроек.Сохранить(ИмяОбработки, , СтруктураНастроек, , ПараметрыСеанса.ТекущийПользователь);
	
КонецПроцедуры

&НаСервере
Процедура ВосстановитьНастройкиНаСервере()
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	
	ИмяОбработки = СокрЛП(ОбработкаОбъект.Метаданные().Имя);
	
	СтруктураНастроек = ХранилищеОбщихНастроек.Загрузить(ИмяОбработки, , , ПараметрыСеанса.ТекущийПользователь);
	Если ТипЗнч(СтруктураНастроек) = Тип("Структура") Тогда
		Для Каждого КлючИЗначение Из СтруктураНастроек Цикл
			Если ОбработкаОбъект.Метаданные().Реквизиты.Найти(КлючИЗначение.Ключ) <> Неопределено Тогда
				Объект[КлючИЗначение.Ключ] = КлючИЗначение.Значение;
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПроверитьЗаполнениеНаСервере()
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	
	Возврат ОбработкаОбъект.ПроверитьЗаполнение();
	
КонецФункции

&НаСервере
Процедура СоздатьДокументыНаСервере(стрАдресФайлаОбмена, НомерГТД, стрИмяФайла)
	
	Попытка
		двИмяФайлаОбмена = ПолучитьИзВременногоХранилища(стрАдресФайлаОбмена);
		стрИмяФайлаОбмена = КаталогВременныхФайлов() + стрИмяФайла;
		двИмяФайлаОбмена.Записать(стрИмяФайлаОбмена);
		
		ТаблицаЗначений	= ДанныеФормыВЗначение(ТаблицаЗначенийДокументы, Тип("ТаблицаЗначений"));
		
		ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
		стрАдресОтвета = ОбработкаОбъект.ПолучитьДанныеЗаполненияДокументов(стрИмяФайлаОбмена, ЭтаФорма, НомерГТД);
		ДанныеЗаполнения = ПолучитьИзВременногоХранилища(стрАдресОтвета); 
		Если НЕ ДанныеЗаполнения.Получить("ФайлОбработанУспешно") Тогда
			Сообщение = "Произошла ошибка при разборе файла ГТД" + Символы.ВК + "Возможно он неподдерживаемого формата"; 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);
			Возврат;	
		КонецЕсли;
		
		СоздатьДокумент(ДанныеЗаполнения, ТаблицаЗначений); 
		ЗначениеВДанныеФормы(ТаблицаЗначений, ТаблицаЗначенийДокументы);
		УдалитьФайлы(стрИмяФайлаОбмена);  
	Исключение
        Сообщение = "Ошибка работы с файлом:" + ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()); 
				
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);
	КонецПопытки;
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьДокументыНаКлиенте()

	Попытка	
		Если ПроверитьЗаполнениеНаСервере() Тогда
			Состояние("Создание документов...");
			двИмяФайлаОбмена = Новый ДвоичныеДанные(Объект.ИмяФайлаОбмена);
			стрАдресФайлаОбмена = ПоместитьВоВременноеХранилище(двИмяФайлаОбмена, ЭтаФорма.УникальныйИдентификатор);
			Файл = Новый Файл(Объект.ИмяФайлаОбмена);
			СоздатьДокументыНаСервере(стрАдресФайлаОбмена, НомерГТД, Файл.Имя);
			Состояние("Создание документов завершено");
		КонецЕсли;
	Исключение
		Сообщение = "Ошибка работы с файлом:" + ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()); 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);
	КонецПопытки; 
	
КонецПроцедуры

&НаКлиенте
Процедура кСоздатьДокументы(Команда)
	
	ОчиститьСообщения();
	Если НЕ ФайлГТДСуществует(НомерГТД) Тогда
		СоздатьДокументыНаКлиенте();
	КонецЕсли; 
	
КонецПроцедуры

&НаКлиенте
Процедура ТаблицаЗначенийДокументыВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ТекЗначение = Элементы.ТаблицаЗначенийДокументы.ТекущиеДанные;
	Если ТекЗначение <> Неопределено Тогда
		ПоказатьЗначение(, ТекЗначение.ДокументСсылка);
	КонецЕсли;
	
	СтандартнаяОбработка = Ложь;
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ВосстановитьНастройкиНаСервере();
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	
	СохранитьНастройкиНаСервере();
	
КонецПроцедуры

// Продолжение процедуры (см. выше).
&НаКлиенте
Процедура ОткрытьКаталогСФайлом(КодВозврата, ДополнительныеПараметры) Экспорт
	// Обработка не требуется.
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаОбменаОткрытие(Элемент, СтандартнаяОбработка)
	
	ОткрытьВПриложении(Элемент.ТекстРедактирования, СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаОбменаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ВыборФайла(Элемент, Объект.ИмяФайлаОбмена, Ложь, , Ложь);
	
КонецПроцедуры

// Открывает диалог выбора файла.
//
// Параметры:
//  Элемент                - Элемент управления, для которого выбираем файл.
//	ИмяСвойства            - Строка, имя файла обмена.
//  ПроверятьСуществование - Если Истина, то выбор отменяется если файл не существует.
//	РасширениеПоУмолчанию  - "xml".
//	АрхивироватьФайлДанных - Булево.
//	ВыборФайлаПравил - Булево.
&НаКлиенте
Процедура ВыборФайла(Элемент, ИмяСвойства, ПроверятьСуществование, Знач РасширениеПоУмолчанию = "xml",
	АрхивироватьФайлДанных = Истина, ВыборФайлаПравил = Ложь)
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбораФайла.Фильтр = "Файл данных (*.xml)|*.xml";
	ДиалогВыбораФайла.Расширение = "xml";
	
	ДиалогВыбораФайла.Заголовок = НСтр("ru = 'Выберите файл'");
	ДиалогВыбораФайла.ПредварительныйПросмотр = Ложь;
	ДиалогВыбораФайла.ИндексФильтра = 0;
	ДиалогВыбораФайла.ПолноеИмяФайла = Элемент.ТекстРедактирования;
	ДиалогВыбораФайла.ПроверятьСуществованиеФайла = ПроверятьСуществование;
	
	Если ДиалогВыбораФайла.Выбрать() Тогда
		
		ИмяСвойства = ДиалогВыбораФайла.ПолноеИмяФайла;
		ИмяФайлаОбменаПриИзмененииНаКлиенте();
		
	КонецЕсли;
	
КонецПроцедуры

// Открывает файл обмена во внешнем приложении.
//
// Параметры:
//  
// 
&НаКлиенте
Процедура ОткрытьВПриложении(ИмяФайла, СтандартнаяОбработка = Ложь)
	
	СтандартнаяОбработка = Ложь;
	
	ДополнительныеПараметры = Новый Структура();
	ДополнительныеПараметры.Вставить("ИмяФайла", ИмяФайла);
	
	ОповещениеОткрытьКаталог = Новый ОписаниеОповещения("ОткрытьКаталогСФайлом", ЭтотОбъект, ДополнительныеПараметры);
	ДополнительныеПараметры.Вставить("ОписаниеОповещения", ОповещениеОткрытьКаталог);
	
	Файл = Новый Файл();
	ОповещениеПроверить = Новый ОписаниеОповещения("ПроверитьСуществованиеФайла", ЭтотОбъект, ДополнительныеПараметры);
	Файл.НачатьИнициализацию(ОповещениеПроверить, ИмяФайла);
	
КонецПроцедуры

// Продолжение процедуры (см. выше).
&НаКлиенте
Процедура ПроверитьСуществованиеФайла(Файл, ДополнительныеПараметры) Экспорт
	ОписаниеОповещения = Новый ОписаниеОповещения("ПослеОпределенияСуществованияФайла", ЭтотОбъект, 
													ДополнительныеПараметры);
	Файл.НачатьПроверкуСуществования(ОписаниеОповещения);
КонецПроцедуры

// Продолжение процедуры (см. выше).
&НаКлиенте
Процедура ПослеОпределенияСуществованияФайла(Существует, ДополнительныеПараметры) Экспорт
	
	Если Существует Тогда
		НачатьЗапускПриложения(ДополнительныеПараметры.ОписаниеОповещения, ДополнительныеПараметры.ИмяФайла);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ИмяФайлаОбменаПриИзмененииНаСервере(стрАдресФайлаОбмена, стрИмяФайла)
	
	Элементы.ФормаСоздатьДокументы.Доступность =  Ложь; 
	СтруктураРезультат = Новый Структура
	("Результат, ФорматФайла, НомерГТД, Грузополучатель, Сумма, Дата, Значение_УникальныйИдентификаторИсходногоДокумента");

	СтруктураРезультат.Результат = Ложь;
	
	Попытка
		двИмяФайлаОбмена = ПолучитьИзВременногоХранилища(стрАдресФайлаОбмена);
		стрИмяФайлаОбмена = КаталогВременныхФайлов() + стрИмяФайла;
		двИмяФайлаОбмена.Записать(стрИмяФайлаОбмена);
		
		ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
		ОбработкаОбъект.ПредварительнаяЗагрузкаФайла(стрИмяФайлаОбмена, СтруктураРезультат);
		Если СтруктураРезультат.Результат Тогда
			Если НЕ ПустаяСтрока(СтруктураРезультат.НомерГТД) И ФайлГТДСуществует(СтруктураРезультат.НомерГТД) Тогда
				СтруктураРезультат.Результат = Ложь;
				Сообщение = "Таможенная декларация на импорт по номеру ГТД " + СтруктураРезультат.НомерГТД + " был создан ранее.";
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);
			КонецЕсли; 	
		КонецЕсли;
		Элементы.ФормаСоздатьДокументы.Доступность =  СтруктураРезультат.Результат;
		УдалитьФайлы(стрИмяФайлаОбмена);  
	Исключение
		Сообщение = "Ошибка работы с файлом:" + ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()); 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);
	КонецПопытки;
	
	Возврат СтруктураРезультат;
	
КонецФункции

&НаКлиенте
Процедура ИмяФайлаОбменаПриИзмененииНаКлиенте()
	
	Соответствие.Очистить();
	ОчиститьСообщения();
	ТаблицаЗначенийДокументы.Очистить();
	Элементы.ФормаСоздатьДокументы.Доступность = Ложь;
	Дата = "";
	Грузополучатель = "";
	Сумма = "";
	Файл = Новый Файл(Объект.ИмяФайлаОбмена);
	
	Если НЕ Файл.Существует() Тогда
		Возврат;
	КонецЕсли;
	
	Если НЕ ПустаяСтрока(Объект.ИмяФайлаОбмена) Тогда
		двИмяФайлаОбмена = Новый ДвоичныеДанные(Объект.ИмяФайлаОбмена);
		стрАдресФайлаОбмена = ПоместитьВоВременноеХранилище(двИмяФайлаОбмена, ЭтаФорма.УникальныйИдентификатор);
		СтруктураРезультат = ИмяФайлаОбменаПриИзмененииНаСервере(стрАдресФайлаОбмена, Файл.Имя);
		Элементы.ФормаСоздатьДокументы.Доступность = СтруктураРезультат.Результат;
		Дата = СтруктураРезультат.Дата;
		Грузополучатель = СтруктураРезультат.Грузополучатель;
		Сумма = СтруктураРезультат.Сумма;
		ФорматФайла = СтруктураРезультат.ФорматФайла;
		НомерГТД = СтруктураРезультат.НомерГТД;
	КонецЕсли; 
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяФайлаОбменаПриИзменении(Элемент)
	ИмяФайлаОбменаПриИзмененииНаКлиенте();
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ИмяФайлаОбменаПриИзмененииНаКлиенте(); 
	Объект.СтоимостьБратьИз = 1;
	Объект.ПоискНоменклатурыПоАртикулу = Истина;
КонецПроцедуры

&НаСервере
Процедура СоздатьДокумент(ДанныеЗаполнения, ТаблицаЗначенийДокументы) Экспорт
	
	Если  ЭтоТаблицаЗначений(ТаблицаЗначенийДокументы) Тогда
		ТаблицаЗначенийДокументы.Очистить();
		
		ПоступлениеТоваровУслуг	= Объект.ПриобретениеТоваровУслуг;
		
		Если ВариантКомплектацииЗаполнен(ДанныеЗаполнения.Получить("ГТД_Товары")) Тогда
			НачатьТранзакцию();
			Попытка
				
				ГТДИмпорт = СоздатьДокументГТДИмпортНаСервере(ДанныеЗаполнения, ПоступлениеТоваровУслуг);
				ЗафиксироватьТранзакцию();
			Исключение
				ОтменитьТранзакцию();
				Сообщение = "Ошибка записи документа:" + ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()); 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);
			КонецПопытки;
			
			Попытка
				ГТДИмпортОбъект = ГТДИмпорт.ПолучитьОбъект();
				ГТДИмпортОбъект.Записать(РежимЗаписиДокумента.Проведение);
			Исключение
				Сообщение = "Ошибка записи документа:" + ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()); 
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);
			КонецПопытки;

		Иначе
			Сообщение = "Не найдены варианты комплектации указанные в контейнере. Создание ГТД производиться не будет."; 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);
		КонецЕсли;
		
		НоваяСтрока = ТаблицаЗначенийДокументы.Добавить();
		НоваяСтрока.ДокументСсылка = ПоступлениеТоваровУслуг;
		НоваяСтрока = ТаблицаЗначенийДокументы.Добавить();
		НоваяСтрока.ДокументСсылка = ГТДИмпорт;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьКонтрагентаПоПартнеру() 

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Контрагенты.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Контрагенты КАК Контрагенты
		|ГДЕ
		|	Контрагенты.гф_КодПартнера = &КодПартнера";
	
	Запрос.УстановитьПараметр("КодПартнера", Объект.ГТДИмпорт_Партнер.Код);
	
		РезультатЗапроса = Запрос.Выполнить();
		
		Выборка = РезультатЗапроса.Выбрать();
		
		Если Не РезультатЗапроса.Пустой() Тогда
			Выборка.Следующий();		
			Возврат Выборка.Ссылка;
		КонецЕсли;
		
	Возврат Неопределено;

КонецФункции

&НаСервере
Функция ГТДИмпортПолучитьДанныеШапкиНаСервере(ДанныеЗаполнения)
	
	Результат = Новый Структура;
	
	Результат.Вставить("Дата",					ДанныеЗаполнения.Получить("ДатаДокумента"));
	Результат.Вставить("ДатаПлатежа",			ДанныеЗаполнения.Получить("ДатаДокумента"));
	Результат.Вставить("Валюта",				ДанныеЗаполнения.Получить("ВалютаДокумента"));
	Результат.Вставить("ВалютаВзаиморасчетов",	ДанныеЗаполнения.Получить("ВалютаДокумента"));  
	Результат.Вставить("Договор",				Объект.ГТДИмпорт_ДоговорКонтрагента);
	Результат.Вставить("Поставщик",				Объект.ПриобретениеТоваровУслуг.Партнер);   // из ПТУ
	Результат.Вставить("КонтрагентПоставщика",	Объект.ПриобретениеТоваровУслуг.Контрагент); // из ПТУ
	Результат.Вставить("Партнер",				Объект.ГТДИмпорт_Партнер);
	Результат.Вставить("Контрагент",			ПолучитьКонтрагентаПоПартнеру());
	Результат.Вставить("ИспользоватьРазделы",	Истина);
	Результат.Вставить("СтатьяРасходовШтраф",	Объект.ГТДИмпорт_СтатьяПрочихДоходовРасходов);
	                              
	Результат.Вставить("Статус",				Перечисления.СтатусыТаможенныхДеклараций.ВыпущеноСТаможни);
	Результат.Вставить("ХозяйственнаяОперация",	Перечисления.ХозяйственныеОперации.ОформлениеГТДСамостоятельно);
	Результат.Вставить("КратностьВзаиморасчетов",	1);
	Результат.Вставить("КратностьДокумента",		1);
	Результат.Вставить("КурсВзаиморасчетов",	Макс(1, ДанныеЗаполнения.Получить("КурсВзаиморасчетов")));
	Результат.Вставить("КурсДокумента",			Макс(1, ДанныеЗаполнения.Получить("КурсВзаиморасчетов")));
	Результат.Вставить("НДСПредъявленКВычету",	Ложь);
	
	НомерГТД = НайтиНомерГТД(ДанныеЗаполнения.Получить("НомерГТД"), ДанныеЗаполнения.Получить("СтранаПроисхождения"));
	
	Результат.Вставить("НомерДекларации",		НомерГТД);
	
	Результат.Вставить("Организация",			Объект.Организация);
	Результат.Вставить("Менеджер",				ПараметрыСеанса.ТекущийПользователь);
	Результат.Вставить("РучнаяКорректировка",	Ложь);
	Результат.Вставить("ТаможенныйСбор",		ДанныеЗаполнения.Получить("ГТД_ТаможенныйСбор"));
	Результат.Вставить("ТаможенныйСборВал",		ДанныеЗаполнения.Получить("ГТД_ТаможенныйСборВал"));
	Результат.Вставить("ТаможенныйШтраф",		ДанныеЗаполнения.Получить("ГТД_ТаможенныйШтраф"));
	Результат.Вставить("ТаможенныйШтрафВал",	ДанныеЗаполнения.Получить("ГТД_ТаможенныйШтрафВал"));
	Результат.Вставить("ВариантОформления",		Перечисления.ХозяйственныеОперации.ОформлениеГТДБрокером);  
	Результат.Вставить("СтатьяРасходовСбор",	Объект.ГТДИмпорт_СтатьяПрочихДоходовРасходов);
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция ГТДИмпортПолучитьДанныеРазделыНаСервере(ДанныеЗаполнения)
	
	ТекЗначение = ДанныеЗаполнения.Получить("ГТД_Разделы");
	Если ЭтоТаблицаЗначений(ТекЗначение) Тогда
		Результат = ТекЗначение;
		Результат.ЗаполнитьЗначения(Объект.ПриобретениеТоваровУслуг.Склад, "Склад");
		Результат.ЗаполнитьЗначения(ПолучитьСтавкуНДС20(), "СтавкаНДС");
	Иначе
		Результат = Документы.ГТДИмпорт.ПустаяСсылка().Разделы.ВыгрузитьКолонки();
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Функция ПолучитьСтавкуНДС20()
	
  	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СтавкиНДС.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.СтавкиНДС КАК СтавкиНДС
		|ГДЕ
		|	СтавкиНДС.Наименование = &Наименование";
	
	Запрос.УстановитьПараметр("Наименование", "20%");
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если Не РезультатЗапроса.Пустой() Тогда
		Выборка = РезультатЗапроса.Выбрать();
		
		Выборка.Следующий();
		
		Возврат Выборка.Ссылка;
	КонецЕсли;

КонецФункции

&НаСервере
Функция ГТДИмпортПолучитьДанныеТоварыНаСервере(ДанныеЗаполнения, ДокументПартии)
	
	ТекЗначение = ДанныеЗаполнения.Получить("ГТД_Товары"); 
	Маркировки = ДанныеЗаполнения.Получить("ГТД_Маркировки");
	ЗаполнитьНомерГТДВСправочникеМаркировок(Маркировки);
	
	ТаблицаТоваров = ТекЗначение.СкопироватьКолонки();
	Колонка = ТаблицаТоваров.Колонки.Найти("ВариантКомплектации");
	ТаблицаТоваров.Колонки.Удалить(Колонка); 
	
	Если ЭтоТаблицаЗначений(ТекЗначение) Тогда
		
		Для каждого Стр Из ТекЗначение Цикл
			Если ЗначениеЗаполнено(Стр.ВариантКомплектации) Тогда
				ДополнитьТаблицуТоваровНоменклатурой(ТаблицаТоваров, Стр);
			Иначе
				Возврат Документы.ТаможеннаяДекларацияИмпорт.ПустаяСсылка().Товары.ВыгрузитьКолонки();
			КонецЕсли;
		КонецЦикла;
		//Еще сверка с таб по маркировкам
		//Если ТаблицаНомПоМаркировкам.Количество()>0 Тогда
		//СверитьТаблицуСТаблицейМаркировок(ТаблицаТоваров, ТаблицаНомПоМаркировкам);
		//КонецЕсли;
		Результат = ТаблицаТоваров;
		Результат.ЗаполнитьЗначения(ДокументПартии, "ДокументПоступления");
		Результат.ЗаполнитьЗначения(Объект.ПриобретениеТоваровУслуг.Склад, "Склад");
		Для каждого Строка Из Результат Цикл
			Строка.НомерДляСФ = СокрЛП(ДанныеЗаполнения.Получить("НомерГТД")) + "/" + СокрЛП(Строка.НомерРаздела);
		КонецЦикла; 
	Иначе
		Результат = Документы.ТаможеннаяДекларацияИмпорт.ПустаяСсылка().Товары.ВыгрузитьКолонки();
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Процедура СверитьТаблицуСТаблицейМаркировок(ТаблицаТоваров, ТаблицаНомПоМаркировкам);

  ТаблицаТоваровКопия = ТаблицаТоваров.Скопировать(, "Номенклатура, Характеристика, Количество");
  
  Если Не ОбщегоНазначения.КоллекцииИдентичны(ТаблицаТоваровКопия, ТаблицаНомПоМаркировкам, , , Истина) Тогда
	  
	  МассивСтрокКУдалению = Новый Массив;
	  
	  Для Каждого Строка Из ТаблицаНомПоМаркировкам Цикл
		  СтруОтбора = Новый Структура;
		  СтруОтбора.Вставить("Номенклатура", Строка.Номенклатура);
		  СтруОтбора.Вставить("Характеристика", Строка.Характеристика);
		  СтруОтбора.Вставить("Количество", Строка.Количество); 
		  Если ТаблицаТоваров.НайтиСтроки(СтруОтбора) = Неопределено Тогда
			  СтруОтбора = Новый Структура;
			  СтруОтбора.Вставить("Номенклатура", Строка.Номенклатура);
			  СтруОтбора.Вставить("Характеристика", Строка.Характеристика);
			  Если ТаблицаТоваров.НайтиСтроки(СтруОтбора) = Неопределено Тогда
				  МассивСтрокКУдалению.Добавить(Строка);
			  Иначе
				  ТаблицаТоваров.НайтиСтроки(СтруОтбора)[0].Количество = Строка.Количество;			
			  КонецЕсли;
		  КонецЕсли;	  
	  КонецЦикла;
	  
	  Если МассивСтрокКУдалению.Количество()>0 Тогда
		  Для каждого Стр Из МассивСтрокКУдалению Цикл
			 ТаблицаТоваров.Удалить(Стр);
		 КонецЦикла;
	 КонецЕсли;
  
  КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура ЗаполнитьНомерГТДВСправочникеМаркировок(Маркировки)
   
   СтруктураМаркировки = ПолучитьСтруктуруПоМаркировке(Маркировки);
   
   Если СтруктураМаркировки.Количество() = 0 Тогда
	   Возврат;
   КонецЕсли; 
   
   Для Каждого Строка Из СтруктураМаркировки Цикл 
	   
	   ОбъектШтрихкодУТ = Строка.Ссылка.ПолучитьОбъект();
	   ОбъектШтрихкодУТ.гф_НомерГТД = НомерГТДСсылка;
	   ОбъектШтрихкодУТ.Записать();
	   
   КонецЦикла;
   
 КонецПроцедуры 

&НаСервере
Функция ПолучитьСтруктуруПоМаркировке(Маркировки)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ШтрихкодыУпаковокТоваров.Ссылка КАК Ссылка,
		|	ШтрихкодыУпаковокТоваров.Номенклатура КАК Номенклатура,
		|	ШтрихкодыУпаковокТоваров.Характеристика КАК Характеристика
		|ИЗ
		|	Справочник.ШтрихкодыУпаковокТоваров КАК ШтрихкодыУпаковокТоваров
		|ГДЕ
		|	ШтрихкодыУпаковокТоваров.ЗначениеШтрихкода В (&ЗначениеШтрихкода)";
	
	Запрос.УстановитьПараметр("ЗначениеШтрихкода", Маркировки);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	Если Не РезультатЗапроса.Пустой() Тогда
		Возврат РезультатЗапроса.Выгрузить();
	Иначе
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Маркировки указанные в файле в ИБ не найдены.");
		Возврат Неопределено;
	КонецЕсли;

КонецФункции
 
&НаСервере
Процедура ДополнитьТаблицуТоваровНоменклатурой(ТаблицаТоваров, Стр) 
	
	НоваяТаблица = ТаблицаТоваров.СкопироватьКолонки();
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ВариантыКомплектацииНоменклатурыТовары.Номенклатура КАК Номенклатура,
		|	ВариантыКомплектацииНоменклатурыТовары.Характеристика КАК Характеристика,
		|	ВариантыКомплектацииНоменклатурыТовары.КоличествоУпаковок КАК КоличествоУпаковок
		|ИЗ
		|	Справочник.ВариантыКомплектацииНоменклатуры.Товары КАК ВариантыКомплектацииНоменклатурыТовары
		|ГДЕ
		|	ВариантыКомплектацииНоменклатурыТовары.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Стр.ВариантКомплектации);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	НоменклатураПоКомплектации = РезультатЗапроса.Выгрузить();
	
	КоличествоПар = НоменклатураПоКомплектации.Итог("КоличествоУпаковок");
	Коэффициент = Стр.КоличествоУпаковок / КоличествоПар;

	Для каждого СтрокаН Из НоменклатураПоКомплектации Цикл
		
		НоваяСтрока = НоваяТаблица.Добавить();
		ЗаполнитьЗначенияСвойств(НоваяСтрока, Стр);
		НоваяСтрока.Номенклатура = СтрокаН.Номенклатура;
		НоваяСтрока.Характеристика = СтрокаН.Характеристика;
		НоваяСтрока.КоличествоУпаковок = Коэффициент * СтрокаН.КоличествоУпаковок;
	    НоваяСтрока.Количество  = Коэффициент * СтрокаН.КоличествоУпаковок;
		КоэффициентДляСумм = Стр.КоличествоУпаковок / НоваяСтрока.КоличествоУпаковок;
		НоваяСтрока.СтавкаНДС = ПолучитьСтавкуНДС20();
		НоваяСтрока.ТаможеннаяСтоимость = Стр.ТаможеннаяСтоимость / КоэффициентДляСумм;
		НоваяСтрока.Назначение = Справочники.Назначения.гф_Техническое;
		//НоваяСтрока.СуммаПошлины = Стр.СуммаПошлины / КоэффициентДляСумм;
		//НоваяСтрока.СуммаНДС = Стр.СуммаНДС / КоэффициентДляСумм;
	КонецЦикла;
	
	СуммаТоваровИтого = НоваяТаблица.Итог("ТаможеннаяСтоимость");

	Если СуммаТоваровИтого <> Стр.ТаможеннаяСтоимость Тогда
		Количество = 0 ;
		Строка = Неопределено; 
		Для Каждого  СтрокаТЗ Из НоваяТаблица Цикл 
			Если СтрокаТЗ.НомерРаздела = Стр.НомерРаздела
			И СтрокаТЗ.Количество > Количество Тогда  
				Количество = СтрокаТЗ.Количество;
				Строка = СтрокаТЗ; 
			КонецЕсли;
		КонецЦикла;			
		
		Строка.ТаможеннаяСтоимость = Строка.ТаможеннаяСтоимость + (Стр.ТаможеннаяСтоимость - СуммаТоваровИтого); 
			
	КонецЕсли;
	
	Для каждого СтрокаТЗ Из НоваяТаблица Цикл 
		ЗаполнитьЗначенияСвойств(ТаблицаТоваров.Добавить(), СтрокаТЗ) 
	КонецЦикла;  
 
КонецПроцедуры

&НаСервере
Функция СоздатьДокументГТДИмпортНаСервере(ДанныеЗаполнения, ПоступлениеТоваровУслуг)
	
	ДокументСсылка = Документы.ТаможеннаяДекларацияИмпорт.ПустаяСсылка();
	
	ДокументОбъект = ПолучитьДокументОбъектНаСервере("ТаможеннаяДекларацияИмпорт");
	ДокументСсылка = ДокументОбъект.Ссылка;
	ДанныеШапки		= ГТДИмпортПолучитьДанныеШапкиНаСервере(ДанныеЗаполнения);
	ДанныеРазделы	= ГТДИмпортПолучитьДанныеРазделыНаСервере(ДанныеЗаполнения);
	ДанныеТовары	= ГТДИмпортПолучитьДанныеТоварыНаСервере(ДанныеЗаполнения, ПоступлениеТоваровУслуг);
	ТоварыГТД = ДанныеТовары.Скопировать();
	ТоварыПТУ 		= ПоступлениеТоваровУслуг.Товары.Выгрузить();
	СраврнитьТовары(ТоварыГТД, ТоварыПТУ); 
	
	ЗаполнитьЗначенияСвойств(ДокументОбъект, ДанныеШапки);
	ДокументОбъект.Комментарий = ДанныеЗаполнения.Получить("Значение_УникальныйИдентификаторИсходногоДокумента") + " " 
	+ ДанныеЗаполнения.Получить("Комментарий");
	
	Если ДанныеТовары.Количество() > 0  Тогда
		ДокументОбъект.Разделы.Загрузить(ДанныеРазделы);
		ДокументОбъект.Товары.Загрузить(ДанныеТовары);
		
		Для Каждого СтрокаТЗ Из ДокументОбъект.Разделы Цикл
			ГТДИмпортРаспределитьНДСИПошлинуПоРазделуНаСервере(ДокументОбъект, СтрокаТЗ.НомерСтроки);
		КонецЦикла;
		
		Попытка
			ДокументОбъект.Записать(РежимЗаписиДокумента.Запись);
			ДокументСсылка = ДокументОбъект.Ссылка;
			
		Исключение
			Сообщение = "Ошибка записи документа:" + ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()); 
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);
		КонецПопытки;
		
	КонецЕсли;
	Возврат ДокументСсылка;
	
КонецФункции

&НаСервере
Процедура СраврнитьТовары(ТоварыГТД, ТоварыПТУ) 
	
	Соответствие.Очистить();
	
	ТоварыГТД.Свернуть("Номенклатура, Характеристика", "Количество");
	ТоварыПТУ.Свернуть("Номенклатура, Характеристика", "Количество");
	
	Сравнение = Новый ТаблицаЗначений;
	Сравнение.Колонки.Добавить("Артикул");
	Сравнение.Колонки.Добавить("Характеристика", Новый ОписаниеТипов("СправочникСсылка.ХарактеристикиНоменклатуры"));
	Сравнение.Колонки.Добавить("Количество_ПТУ");
	Сравнение.Колонки.Добавить("Количество_ГТД");
	Сравнение.Колонки.Добавить("Значение");
    Сравнение.Колонки.Добавить("Разница");
	
	Для каждого Стр Из ТоварыГТД Цикл
		СтруктураОтбора = Новый Структура("Номенклатура, Характеристика, Количество");		
		ЗаполнитьЗначенияСвойств(СтруктураОтбора, Стр);
		МассивНайденныхВариантов = ТоварыПТУ.НайтиСтроки(СтруктураОтбора);
		Если МассивНайденныхВариантов.Количество() = 0 Тогда
			// Проверяем строки без количества
			СтруктураБезКоличества = Новый Структура("Номенклатура, Характеристика");
			ЗаполнитьЗначенияСвойств(СтруктураБезКоличества, Стр);
			МассивКоличества = ТоварыПТУ.НайтиСтроки(СтруктураБезКоличества);
			Если МассивКоличества.Количество() > 0 Тогда								
				// строки с разным количеством
				СтрокаДляЗаписи = Сравнение.Добавить();
				СтрокаДляЗаписи.Артикул = Стр.Номенклатура.Артикул;
				СтрокаДляЗаписи.Характеристика = Стр.Характеристика;
				СтрокаДляЗаписи.Количество_ПТУ = МассивКоличества[0].Количество;
				СтрокаДляЗаписи.Количество_ГТД = Стр.Количество;
				СтрокаДляЗаписи.Разница = СтрокаДляЗаписи.Количество_ПТУ - СтрокаДляЗаписи.Количество_ГТД; 
				СтрокаДляЗаписи.Значение = 1;	
			Иначе
				СтрокаДляЗаписи = Сравнение.Добавить();
				СтрокаДляЗаписи.Количество_ПТУ = 0;
				СтрокаДляЗаписи.Артикул = Стр.Номенклатура.Артикул;
				СтрокаДляЗаписи.Характеристика = Стр.Характеристика;
				СтрокаДляЗаписи.Количество_ГТД = Стр.Количество;
				СтрокаДляЗаписи.Разница = СтрокаДляЗаписи.Количество_ПТУ - СтрокаДляЗаписи.Количество_ГТД;
				СтрокаДляЗаписи.Значение = 1;
				
			КонецЕсли;	 
		Иначе
			// Если строки одинкаовые то вносим данные со значением "0"
			СтрокаДляЗаписи = Сравнение.Добавить();
			СтрокаДляЗаписи.Артикул = Стр.Номенклатура.Артикул;
			СтрокаДляЗаписи.Характеристика = Стр.Характеристика;
			СтрокаДляЗаписи.Количество_ПТУ = Стр.Количество;
			СтрокаДляЗаписи.Количество_ГТД = Стр.Количество;
			СтрокаДляЗаписи.Разница = 0;
			СтрокаДляЗаписи.Значение = 0;
			
		КонецЕсли;
	КонецЦикла;
	
	Для каждого Стр Из ТоварыПТУ Цикл
		СтруктураОтбора = Новый Структура("Артикул, Характеристика, Количество_ПТУ");		
		
		СтруктураОтбора.Артикул = Стр.Номенклатура.Артикул;
		СтруктураОтбора.Характеристика = Стр.Характеристика; 
		СтруктураОтбора.Количество_ПТУ = Стр.Количество;
		
		МассивНайденныхВариантов = Сравнение.НайтиСтроки(СтруктураОтбора);
		Если МассивНайденныхВариантов.Количество() = 0 Тогда
			
			СтруктураБезКоличества = Новый Структура("Артикул, Характеристика");		
			
			СтруктураБезКоличества.Артикул = Стр.Номенклатура.Артикул;
			СтруктураБезКоличества.Характеристика = Строка(Стр.Характеристика); 
			
			МассивКоличества = Сравнение.НайтиСтроки(СтруктураБезКоличества);
			Если МассивКоличества.Количество() = 0 Тогда
				
				СтрокаДляЗаписи = Сравнение.Добавить();
				СтрокаДляЗаписи.Артикул = Стр.Номенклатура.Артикул;
				СтрокаДляЗаписи.Характеристика = Стр.Характеристика;
				СтрокаДляЗаписи.Количество_ПТУ = Стр.Количество;
				СтрокаДляЗаписи.Количество_ГТД = 0;
				СтрокаДляЗаписи.Разница = СтрокаДляЗаписи.Количество_ПТУ - СтрокаДляЗаписи.Количество_ГТД;
				СтрокаДляЗаписи.Значение = 1;				
				
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;	
	
	Сравнение.Колонки.Добавить("Штрихкод");

	Для каждого Стр Из Сравнение Цикл 
		
		Отбор = Новый Структура;
		Отбор.Вставить("Артикул", Стр.Артикул);
		Отбор.Вставить("Характеристика", стр.Характеристика);
		Штрихкод = НайтиШтрихкодДляНоменклатуры(Отбор);
	    Стр.Штрихкод = Штрихкод;
	КонецЦикла;
	
	Соответствие.Загрузить(Сравнение);
	
	ПереключательСравнения = 2;
	
КонецПроцедуры

&НаСервере
Функция НайтиШтрихкодДляНоменклатуры(Отбор)   

	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ШтрихкодыНоменклатуры.Штрихкод КАК Штрихкод
		|ИЗ
		|	РегистрСведений.ШтрихкодыНоменклатуры КАК ШтрихкодыНоменклатуры
		|ГДЕ
		|	ШтрихкодыНоменклатуры.Характеристика = &Характеристика
		|	И ШтрихкодыНоменклатуры.Номенклатура.Артикул = &Артикул";
	
	Запрос.УстановитьПараметр("Артикул", Отбор.Артикул);
	Запрос.УстановитьПараметр("Характеристика", Отбор.Характеристика);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Если НЕ РезультатЗапроса.Пустой() Тогда
		Выборка.Следующий();
		Возврат Выборка.Штрихкод;
	КонецЕсли;	
		
КонецФункции

&НаСервере
Функция ПолучитьДокументОбъектНаСервере(ТипДокументаСтрокой)
	
	Результат = Документы[ТипДокументаСтрокой].СоздатьДокумент();
	
	Возврат Результат;
	
КонецФункции

&НаСервере
Процедура ГТДИмпортРаспределитьНДСИПошлинуПоРазделуНаСервере(ДокументОбъект, НомерРаздела)
	
	// Проверим, есть ли что распределять.
	СтрокаРаздела = ДокументОбъект.Разделы.Получить(НомерРаздела - 1);
	ТаможеннаяСтоимость = СтрокаРаздела.ТаможеннаяСтоимость;
	СуммаПошлины        = СтрокаРаздела.СуммаПошлины;
	СуммаНДС            = СтрокаРаздела.СуммаНДС;
	
	МассивСтрок  = ДокументОбъект.Товары.НайтиСтроки(Новый Структура("НомерРаздела", НомерРаздела));
	БазисРаспределения = Новый Массив();
	
	ВсегоСтоимость = 0;
	Для каждого ЭлементМассива Из МассивСтрок Цикл
		ВсегоСтоимость = ВсегоСтоимость + ЭлементМассива.ТаможеннаяСтоимость;
		БазисРаспределения.Добавить(ЭлементМассива.ТаможеннаяСтоимость);
	КонецЦикла;
	
	Всего        = ВсегоСтоимость;
	ВсегоПошлина = СуммаПошлины;
	ВсегоНДС     = СуммаНДС;
	
	Если ВсегоСтоимость = 0 Тогда
		
		Если МассивСтрок.Количество() > 0 Тогда
			ТекстСообщения = НСтр("ru='Общая сумма фактурной стоимости раздела %1 нулевая!
			|Распределение невозможно.'");
			ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ТекстСообщения, НомерРаздела);
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ТекстСообщения, , "Товары", "Объект");
		КонецЕсли;
		
		Возврат;
		
	КонецЕсли;
	
	Если Не СуммаПошлины = 0 Тогда
		МассивРезультатаРаспределения_Пошлина = 
						ОбщегоНазначенияУТКлиентСервер.РаспределитьПропорционально(СуммаПошлины, БазисРаспределения);
	КонецЕсли;
	Если Не СуммаНДС = 0 Тогда
		МассивРезультатаРаспределения_НДС = 
						ОбщегоНазначенияУТКлиентСервер.РаспределитьПропорционально(СуммаНДС, БазисРаспределения);
	КонецЕсли;
	
	Для ИндексСтроки = 0 По МассивСтрок.Количество() - 1 Цикл
		Если Не СуммаПошлины = 0 Тогда
			МассивСтрок[ИндексСтроки].СуммаПошлины = МассивРезультатаРаспределения_Пошлина[ИндексСтроки];
		Иначе
			МассивСтрок[ИндексСтроки].СуммаПошлины = 0;
		КонецЕсли;
		Если Не СуммаНДС = 0 Тогда
			МассивСтрок[ИндексСтроки].СуммаНДС = МассивРезультатаРаспределения_НДС[ИндексСтроки];
		Иначе
			МассивСтрок[ИндексСтроки].СуммаНДС = 0;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ФайлГТДСуществует(НомерГТД)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ТаможеннаяДекларацияИмпорт.Ссылка КАК Ссылка
		|ИЗ
		|	Документ.ТаможеннаяДекларацияИмпорт КАК ТаможеннаяДекларацияИмпорт
		|ГДЕ
		|	ТаможеннаяДекларацияИмпорт.НомерДекларации = &НомерДекларации
		|	И ТаможеннаяДекларацияИмпорт.ПометкаУдаления = Ложь";
	
	Запрос.УстановитьПараметр("НомерДекларации", НомерГТД);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Возврат НЕ РезультатЗапроса.Пустой();
	
КонецФункции

&НаСервере
Процедура ОрганизацияПриИзмененииНаСервере()
	
	Если Объект.Организация <> Объект.ПриобретениеТоваровУслуг.Организация Тогда
		Сообщение = "Выбранная организация не совпадает с организацией из ПТУ"; 
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);
		Объект.Организация = Объект.ПриобретениеТоваровУслуг.Организация;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ОрганизацияПриИзменении(Элемент)
	ОрганизацияПриИзмененииНаСервере();
КонецПроцедуры

&НаСервере
Функция НайтиНомерГТД(ЗначениеХДТО, СтранаПроисхождения)

	НомерГТД = Справочники.НомераГТД.ПустаяСсылка(); 
	
	Если ПустаяСтрока(ЗначениеХДТО) 
		Тогда  ЗначениеХДТО = формат(ТекущаяДатаСеанса(), "ДФ=dd/MM/yy/mm/ss") ; 
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
	|	НомераГТД.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.НомераГТД КАК НомераГТД
	|ГДЕ
	|	НомераГТД.ПометкаУдаления = ЛОЖЬ
	|	И НомераГТД.Код = &Код
	|	И НомераГТД.СтранаПроисхождения = &СтранаПроисхождения";
	
	Запрос.УстановитьПараметр("Код", ЗначениеХДТО);
	Запрос.УстановитьПараметр("СтранаПроисхождения", СтранаПроисхождения);
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда  
		
		НовыйНомерГТД = Справочники.НомераГТД.СоздатьЭлемент(); 
		НовыйНомерГТД.Код = ЗначениеХДТО;
		НовыйНомерГТД.СтранаПроисхождения = СтранаПроисхождения;
		Попытка 
			НовыйНомерГТД.Записать();
			НомерГТДСсылка = НовыйНомерГТД.Ссылка;		
		Исключение 
			Сообщение = "Ошибка записи ГТД:" + ОбработкаОшибок.ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю(Сообщение);

		КонецПопытки; 
		
	Иначе  Выборка = РезультатЗапроса.выбрать(); 
		
		Выборка.Следующий();  
		НомерГТДСсылка = Выборка.Ссылка; 
		
	КонецЕсли;
	Возврат НомерГТДСсылка ;
 
КонецФункции

&НаСервере
Функция ВариантКомплектацииЗаполнен(ГТД_Товары)
	
	Для Каждого Стр Из ГТД_Товары Цикл
		Если Стр.ВариантКомплектации = Неопределено 
			ИЛИ Стр.ВариантКомплектации = Справочники.ВариантыКомплектацииНоменклатуры.ПустаяСсылка() Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Истина;
	
КонецФункции

&НаКлиенте
Процедура ПереключательСравненияПриИзменении(Элемент)
	
	Если ПереключательСравнения = 1 Тогда
		Элементы.Соответствие.ОтборСтрок = Новый ФиксированнаяСтруктура("Значение", 1);
	ИначеЕсли ПереключательСравнения = 0 Тогда
		Элементы.Соответствие.ОтборСтрок = Новый ФиксированнаяСтруктура("Значение", 0);
	Иначе
		Элементы.Соответствие.ОтборСтрок = Новый ФиксированнаяСтруктура();
	КонецЕсли;
	
КонецПроцедуры

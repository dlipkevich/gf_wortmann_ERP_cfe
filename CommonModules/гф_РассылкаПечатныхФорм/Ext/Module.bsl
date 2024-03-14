﻿#Область ПрограммныйИнтерфейс

// #wortmann {
// Галфинд Окунев 2022/07/20
//
// Параметры:
//
// Сообщение			- ДокументСсылка
// ИмяПараметра			- Строка
// ЗначениеПараметра	- Произвольный - Значение параметра.
//
Процедура ВставитьПараметрВТекстСообщения(Сообщение, ИмяПараметра, ЗначениеПараметра) Экспорт
	
	Сообщение.Текст = СтрЗаменить(Сообщение.Текст, "&lt;" + ИмяПараметра + "&gt;", ЗначениеПараметра);
	
КонецПроцедуры// } #wortmann

// #wortmann {
// Галфинд Окунев 2022/07/20
//
// Параметры:
//
// Сообщение	- ДокументСсылка
// Организация	- СправочникСсылка - Организация.
//
Процедура ВставитьЛоготипВТекстСообщения(Сообщение, Организация) Экспорт
	
	ФайлКартинки = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Организация, "ФайлЛоготип");
	
	ДвоичныеДанныеФайла = РаботаСФайлами.ДвоичныеДанныеФайла(ФайлКартинки);
	
	АдресКартинки = ПоместитьВоВременноеХранилище(ДвоичныеДанныеФайла);
	
	ВставитьКартинкуВТекстСообщения(Сообщение, "Лого", АдресКартинки);
	
КонецПроцедуры

// #wortmann {
// Галфинд Окунев 2022/09/16
//
// Создает пустую таблицу печатных форм
//
// Возвращаемое значение:
// - ТаблицаЗначений - Колонки:
//
// Параметры:
//
//	Документ					- ДокументСсылка
//	ИдентификаторПечатнойФормы	- Строка
//	ПредставлениеПечатнойФормы	- Строка
//	ИмяФайла					- Строка - имя файла без пути,
//	ФорматФайла					- ТипФайлаТабличногоДокумента
//	Адрес						- Строка - адрес во временном хранилище.
//
Функция ИнициализироватьТаблицуПечатныхФорм() Экспорт
	
	ОписаниеТиповСтрока         = Новый ОписаниеТипов("Строка");
	ОписаниеТиповДокументСсылка = Документы.ТипВсеСсылки();
	ОписаниеТиповФорматФайла    = Новый ОписаниеТипов("ТипФайлаТабличногоДокумента");
	
	ТаблицаПечатныхФорм = Новый ТаблицаЗначений;
	
	ТаблицаПечатныхФорм.Колонки.Добавить("Документ",    ОписаниеТиповДокументСсылка);
	ТаблицаПечатныхФорм.Колонки.Добавить("ИдентификаторПечатнойФормы", ОписаниеТиповСтрока);
	ТаблицаПечатныхФорм.Колонки.Добавить("ПредставлениеПечатнойФормы", ОписаниеТиповСтрока);
	ТаблицаПечатныхФорм.Колонки.Добавить("ИмяФайла",    ОписаниеТиповСтрока);
	ТаблицаПечатныхФорм.Колонки.Добавить("ФорматФайла", ОписаниеТиповФорматФайла);
	ТаблицаПечатныхФорм.Колонки.Добавить("Адрес",       ОписаниеТиповСтрока);
	
	Возврат ТаблицаПечатныхФорм;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// #wortmann {
// Галфинд Окунев 2022/07/20
//
// Параметры:
//
// Сообщение 		- Структура
// ИмяПараметра		- Строка - Имя параметра
// АдресКартинки 	- Строка - Адрес картинки.
//
Процедура ВставитьКартинкуВТекстСообщения(Сообщение, ИмяПараметра, АдресКартинки) Экспорт
	
	Идентификатор = Строка(Новый УникальныйИдентификатор());
	
	Вложение = Сообщение.Вложения.Добавить();
	
	Вложение.АдресВоВременномХранилище = АдресКартинки;
	Вложение.Представление             = ИмяПараметра;
	Вложение.Идентификатор             = Идентификатор;
	
	Сообщение.Текст = СтрЗаменить(Сообщение.Текст,
	"&lt;" + ИмяПараметра + "&gt;",
	"<img src=""cid:" + Идентификатор + """ style=""border:none;""></img>");
	
КонецПроцедуры// } #wortmann

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2022/07/20
//
// Параметры:
//
// ПисьмоСсылка 	- ДокументСсылк
// Сообщение       	- ДокументСсылка
// МассивДокументов	- Массив
// УчетнаяЗапись	- СправочникСсылка
// АдресОтправителя	- Строка
// ПоставитьВКопию	- Булево - ПоставитьВКопию.
//
Процедура СоздатьИлиЗаполнитьПисьмо(ПисьмоСсылка, Сообщение, МассивДокументов,
	УчетнаяЗапись, АдресОтправителя = Неопределено, ПоставитьВКопию = Неопределено) Экспорт
	
	Если ЗначениеЗаполнено(ПисьмоСсылка)
		И ПисьмоСсылка.СтатусПисьма =
		ПредопределенноеЗначение("Перечисление.СтатусыИсходящегоЭлектронногоПисьма.Черновик") Тогда
		
		Письмо = ПисьмоСсылка.ПолучитьОбъект();
		
	Иначе
		
		Письмо = Документы.ЭлектронноеПисьмоИсходящее.СоздатьДокумент();
		//+++ БФ Бобнев К.С. 13.03.24
		ПисьмоСсылка = Документы.ЭлектронноеПисьмоИсходящее.ПолучитьСсылку(Новый УникальныйИдентификатор);
		Письмо.УстановитьСсылкуНового(ПисьмоСсылка);
		//--- БФ Бобнев К.С. 13.03.24
		Письмо.СтатусПисьма = ПредопределенноеЗначение("Перечисление.СтатусыИсходящегоЭлектронногоПисьма.Черновик");
		
	КонецЕсли;
	
	ПисьмоХТМЛ = (Сообщение.ДополнительныеПараметры.ФорматПисьма 
	= Перечисления.СпособыРедактированияЭлектронныхПисем.HTML);
	
	Письмо.Автор     = Пользователи.ТекущийПользователь();
	Письмо.Ответственный            = Пользователи.ТекущийПользователь();
	Письмо.Дата      = ТекущаяДатаСеанса();
	Письмо.Важность  = Перечисления.ВариантыВажностиВзаимодействия.Обычная;
	Письмо.Кодировка = "UTF-8";
	Письмо.ОтправительПредставление = АдресОтправителя;
	Письмо.Дата      = ТекущаяДатаСеанса();
	
	Если ПисьмоХТМЛ Тогда
		
		Письмо.ТекстHTML = Сообщение.Текст;
		Письмо.Текст     = Взаимодействия.ПолучитьОбычныйТекстИзHTML(Сообщение.Текст);
		
	Иначе
		
		Письмо.Текст = Сообщение.Текст;
		
	КонецЕсли;
	
	Письмо.Тема      = Сообщение.Тема;
	Письмо.ТипТекста = ?(ПисьмоХТМЛ, Перечисления.ТипыТекстовЭлектронныхПисем.HTML,
	Перечисления.ТипыТекстовЭлектронныхПисем.ПростойТекст);
	Письмо.УчетнаяЗапись           = УчетнаяЗапись;
	Письмо.ВзаимодействиеОснование = Неопределено;
	
	НастройкиПользователя = Взаимодействия.ПолучитьПараметрыРаботыПользователяДляИсходящегоЭлектронногоПисьма(
	УчетнаяЗапись, Сообщение.ДополнительныеПараметры.ФорматПисьма, Истина);
	ЗаполнитьЗначенияСвойств(Письмо, НастройкиПользователя);
	
	Письмо.УдалятьПослеОтправки = Ложь;
	Письмо.Комментарий          = "Создано и отправлено по шаблону" 
	+ " - " + Сообщение.ДополнительныеПараметры.Наименование;
	
	СписокПолучателейСпискомЗначений = (ТипЗнч(Сообщение.Получатель) = Тип("СписокЗначений"));
	
	Письмо["ПолучателиПисьма"].Очистить();
	
	Для Каждого ПолучательПисьма Из Сообщение.Получатель Цикл
		
		НоваяСтрока = Письмо["ПолучателиПисьма"].Добавить();
		
		Если СписокПолучателейСпискомЗначений Тогда
			
			НоваяСтрока.Адрес         = ПолучательПисьма.Значение;
			НоваяСтрока.Представление = ПолучательПисьма.Представление;
			
		Иначе
			
			НоваяСтрока.Адрес         = ПолучательПисьма.Адрес;
			НоваяСтрока.Представление = ПолучательПисьма.Представление;
			НоваяСтрока.Контакт       = ПолучательПисьма.ИсточникКонтактнойИнформации;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Письмо.СписокПолучателейПисьма = ВзаимодействияКлиентСервер.ПолучитьПредставлениеСпискаАдресатов(
	Письмо.ПолучателиПисьма,
	Ложь);
	
	Письмо.ПолучателиКопий.Очистить();
	
	МассивПолучателейКопий = СтрРазделить(ПоставитьВКопию, ";", Ложь);
	
	Для Каждого ПолучательКопии Из МассивПолучателейКопий Цикл
		
		СтрокаПолучателяКопии = Письмо.ПолучателиКопий.Добавить();
		
		СтрокаПолучателяКопии.Адрес = ПолучательКопии;
		
	КонецЦикла;
	
	Письмо.СписокПолучателейКопий = ВзаимодействияКлиентСервер.ПолучитьПредставлениеСпискаАдресатов(
	Письмо.ПолучателиКопий,
	Ложь);
	
	
	ОбработатьВложения(Письмо, Сообщение, МассивДокументов, ПисьмоХТМЛ);
	
КонецПроцедуры

// #wortmann {
// #Спецификация покупателя
// Галфинд Окунев 2023/06/18
//
// Параметры:
//
// Письмо				- ДокументСсылка
// Сообщение			- ДокументСсылка
// МассивДокументов		- Массив
// ПисьмоХТМЛ			- Булево
//
Процедура ОбработатьВложения(Письмо, Сообщение, МассивДокументов, ПисьмоХТМЛ)
	
	Письмо.ЕстьВложения = (Сообщение.Вложения.Количество() > 0);
	
	РазмерВложений  = 0;
	РазмерыВложений = Новый Соответствие;
	
	Для Каждого Вложение Из Сообщение.Вложения Цикл
		
		Полтора = 1.5;
		
		Размер = ПолучитьИзВременногоХранилища(Вложение.АдресВоВременномХранилище).Размер() * Полтора;
		
		РазмерВложений = РазмерВложений + Размер;
		
		РазмерыВложений.Вставить(Вложение.АдресВоВременномХранилище, Размер);
		
		Если ЗначениеЗаполнено(Вложение.Идентификатор) Тогда
			
			Идентификатор = СтроковыеФункции.СтрокаЛатиницей(Вложение.Идентификатор);
			
			Письмо.ТекстHTML = СтрЗаменить(Письмо.ТекстHTML, "cid:" + Вложение.Идентификатор, "cid:" + Идентификатор);
			
			Вложение.Идентификатор = Идентификатор;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Два = 2;
	
	Письмо.Размер = РазмерВложений + СтрДлина(Письмо.Тема) * Два
	+ ?(ПисьмоХТМЛ, СтрДлина(Письмо.ТекстHTML), СтрДлина(Письмо.Текст)) * Два;
	
	ПрикрепленныеДокументы = Письмо.гф_ПрикрепленныеДокументы;
	
	ПрикрепленныеДокументы.Очистить();
	
	Для Каждого Документ Из МассивДокументов Цикл
		
		ПрикрепленныйДокумент = ПрикрепленныеДокументы.Добавить();
		
		ПрикрепленныйДокумент.Документ = Документ;
		
	КонецЦикла;
	
	Письмо.Записать();
	
	ПисьмоСсылка = Письмо.Ссылка;
	
	Запрос = Новый Запрос;
	
	Запрос.Текст = "ВЫБРАТЬ
	|	ЭлектронноеПисьмоИсходящееПрисоединенныеФайлы.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.ЭлектронноеПисьмоИсходящееПрисоединенныеФайлы КАК ЭлектронноеПисьмоИсходящееПрисоединенныеФайлы
	|ГДЕ
	|	ЭлектронноеПисьмоИсходящееПрисоединенныеФайлы.ВладелецФайла = &ВладелецФайла";
	
	Запрос.Параметры.Вставить("ВладелецФайла", ПисьмоСсылка);
	
	Выборка = Запрос.Выполнить().Выбрать();
	// ++ ЕсиповАВ Галфинд 02.02.2024
	УстановитьПривилегированныйРежим(Истина);
	// -- ЕсиповАВ Галфинд 02.02.2024
	Пока Выборка.Следующий() Цикл
		
		ПрисоединенныйФайл = Выборка.Ссылка.ПолучитьОбъект();
		
		ПрисоединенныйФайл.Удалить();
		
	КонецЦикла;
	// ++ ЕсиповАВ Галфинд 02.02.2024
	УстановитьПривилегированныйРежим(Ложь);
	// -- ЕсиповАВ Галфинд 02.02.2024
	
	Для Каждого Вложение Из Сообщение.Вложения Цикл
		
		ПараметрыВложения = Новый Структура;
		ПараметрыВложения.Вставить("ИмяФайла", Вложение.Представление);
		ПараметрыВложения.Вставить("Размер",   РазмерыВложений[Вложение.АдресВоВременномХранилище]);
		
		Если ПустаяСтрока(Вложение.Идентификатор) Тогда
			
			УправлениеЭлектроннойПочтой.ЗаписатьВложениеЭлектронногоПисьмаИзВременногоХранилища(Письмо.Ссылка,
			Вложение.АдресВоВременномХранилище, ПараметрыВложения);
			
		ИначеЕсли ПисьмоХТМЛ Тогда
			
			ПараметрыВложения.Вставить("ИДФайлаЭлектронногоПисьма", Вложение.Идентификатор);
			
			УправлениеЭлектроннойПочтой.ЗаписатьВложениеЭлектронногоПисьмаИзВременногоХранилища(Письмо.Ссылка,
			Вложение.АдресВоВременномХранилище, ПараметрыВложения);
			
		Иначе
			
			Продолжить;
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры// } #wortmann

// #wortmann {
// Галфинд Окунев 2022/09/16
//
// Формирует и помещает во временное хранилище печатные формы документа
//
// Параметры:
//
// ТаблицаПечатныхФорм			- ТаблицаЗначений 	- см. функцию ИнициализироватьТаблицуПечатныхФорм()
// УникальныйИдентификаторФормы	- УникальныйИдентификатор
// Ошибки						- Массив - см. ОбщегоНазначенияКлиентСервер.ДобавитьОшибкуПользователю().
//
Процедура ВывестиДокументыВТаблицуПечатныхФорм(ТаблицаПечатныхФорм,
	УникальныйИдентификаторФормы,
	Ошибки = Неопределено) Экспорт
	
	Для Каждого ПечатнаяФорма Из ТаблицаПечатныхФорм Цикл
		
		ВывестиДокументВТаблицуПечатныхФорм(ПечатнаяФорма, УникальныйИдентификаторФормы, Ошибки);
		
	КонецЦикла;
	
КонецПроцедуры// } #wortmann

// #wortmann {
// Галфинд Окунев 2022/09/16
//
// Формирует и помещает во временное хранилище печатные формы документа
//
// Параметры:
//
// ПечатнаяФорма				- Строка
// УникальныйИдентификаторФормы	- Строка
// Ошибки						- Массив - см. ОбщегоНазначенияКлиентСервер.ДобавитьОшибкуПользователю().
//
Процедура ВывестиДокументВТаблицуПечатныхФорм(ПечатнаяФорма, УникальныйИдентификаторФормы, Ошибки = Неопределено)
	
	МассивОбъектов = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(ПечатнаяФорма.Документ);
	
	Если ЗначениеЗаполнено(ПечатнаяФорма.ФорматФайла) Тогда
		
		ФорматФайла = ПечатнаяФорма.ФорматФайла;
		
	Иначе
		
		ФорматФайла = ТипФайлаТабличногоДокумента.PDF;
		
	КонецЕсли;
	
	НастройкиСохранения = УправлениеПечатью.НастройкиСохранения();
	
	НастройкиСохранения.ФорматыСохранения.Добавить(ФорматФайла);
	
	КомандыПечати = УправлениеПечатью.КомандыПечатиОбъектаДоступныеДляВложений(ПечатнаяФорма.Документ.Метаданные());
	
	// ++ Галфинд_ДомнышеваКР_13_02_2024
	Если ПечатнаяФорма.ПредставлениеПечатнойФормы = "Счет на оплату с факсимиле (подписи)" Тогда
		КомандаПечати = КомандыПечати.Найти(ПечатнаяФорма.ПредставлениеПечатнойФормы, "Представление");
	Иначе 
	// -- Галфинд_ДомнышеваКР_13_02_2024
	КомандаПечати = КомандыПечати.Найти(ПечатнаяФорма.ИдентификаторПечатнойФормы, "Идентификатор");		
	КонецЕсли;// Галфинд_ДомнышеваКР_13_02_2024

	Если КомандаПечати <> Неопределено Тогда
		
		ДанныеФайлов = УправлениеПечатью.НапечататьВФайл(КомандаПечати, МассивОбъектов, НастройкиСохранения);
		
		Если ДанныеФайлов.Количество() Тогда
			
			АдресФайла = ПоместитьВоВременноеХранилище(ДанныеФайлов[0].ДвоичныеДанные, УникальныйИдентификаторФормы);
			
			ПечатнаяФорма.Адрес = АдресФайла;
			
			Если Не ЗначениеЗаполнено(ПечатнаяФорма.ИмяФайла) Тогда
				
				ПечатнаяФорма.ИмяФайла = ДанныеФайлов[0].ИмяФайла;
				
			Иначе
				
				ПечатнаяФорма.ИмяФайла = ОбщегоНазначенияКлиентСервер.ЗаменитьНедопустимыеСимволыВИмениФайла(
				ПечатнаяФорма.ИмяФайла, "_");
				
			КонецЕсли;
			
		Иначе
			
			СтрокаОшибки = СтрШаблон("Для документа %1 нет данных для печати формы %2",
			ПечатнаяФорма.Документ, ПечатнаяФорма.ПредставлениеПечатнойФормы);
			
			ОбщегоНазначенияКлиентСервер.ДобавитьОшибкуПользователю(Ошибки, "", СтрокаОшибки);
			
		КонецЕсли;
		
	Иначе
		
		СтрокаОшибки = СтрШаблон("Для документа %1 не найдена команда печати для печатной формы %2",
		ПечатнаяФорма.Документ, ПечатнаяФорма.ПредставлениеПечатнойФормы);
		
		ОбщегоНазначенияКлиентСервер.ДобавитьОшибкуПользователю(Ошибки, "", СтрокаОшибки);
		
	КонецЕсли;
	
КонецПроцедуры// } #wortmann

#КонецОбласти
